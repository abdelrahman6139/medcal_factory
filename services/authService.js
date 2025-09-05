// services/authService.js
const crypto = require('crypto');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const asyncHandler = require('express-async-handler');
const { OAuth2Client } = require('google-auth-library');

const ApiError = require('../utils/apiError');
const sendEmail = require('../utils/sendEmail');
const createToken = require('../utils/createToken'); // expects { id }
const User = require('../models/userModel');

// Helpers
const toSafeUser = (u) => ({
  id: u._id,
  name: u.name,
  email: u.email,
  role: u.role,
});

// @desc    Signup
// @route   POST /api/v1/auth/signup
// @access  Public
exports.signup = asyncHandler(async (req, res) => {
  const user = await User.create({
    name: req.body.name,
    email: req.body.email,
    password: req.body.password,
  });

  const token = createToken({ id: user._id });
  res.status(201).json({ data: toSafeUser(user), token });
});

// @desc    Login
// @route   POST /api/v1/auth/login
// @access  Public
exports.login = asyncHandler(async (req, res, next) => {
  const { email, password } = req.body;

  const user = await User.findOne({ email }).select('+password');
  if (!user || !(await bcrypt.compare(password, user.password))) {
    return next(new ApiError('Incorrect email or password', 401));
  }

  const token = createToken({ id: user._id });
  user.password = undefined;

  res.status(200).json({ data: toSafeUser(user), token });
});

// @desc   Protect routes (auth middleware)
// @access Private
exports.protect = asyncHandler(async (req, res, next) => {
  let token;
  if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
    token = req.headers.authorization.split(' ')[1];
  }
  if (!token) return next(new ApiError('You are not login, Please login to get access this route', 401));

  const decoded = jwt.verify(token, process.env.JWT_SECRET);

  const currentUser = await User.findById(decoded.id);
  if (!currentUser) {
    return next(new ApiError('The user that belong to this token does no longer exist', 401));
  }

  if (currentUser.passwordChangedAt) {
    const passChangedTimestamp = parseInt(currentUser.passwordChangedAt.getTime() / 1000, 10);
    if (passChangedTimestamp > decoded.iat) {
      return next(new ApiError('User recently changed his password. please login again..', 401));
    }
  }

  req.user = currentUser;
  next();
});

// @desc    Authorization (User Permissions)
// @access  Private
exports.allowedTo = (...roles) =>
  asyncHandler(async (req, res, next) => {
    if (!roles.includes(req.user.role)) {
      return next(new ApiError('You are not allowed to access this route', 403));
    }
    next();
  });

// @desc    Forgot password
// @route   POST /api/v1/auth/forgotPassword
// @access  Public
exports.forgotPassword = asyncHandler(async (req, res, next) => {
  const user = await User.findOne({ email: req.body.email });
  if (!user) return next(new ApiError(`There is no user with that email ${req.body.email}`, 404));

  const resetCode = Math.floor(100000 + Math.random() * 900000).toString();
  const hashedResetCode = crypto.createHash('sha256').update(resetCode).digest('hex');

  user.passwordResetCode = hashedResetCode;
  user.passwordResetExpires = Date.now() + 10 * 60 * 1000; // 10 min
  user.passwordResetVerified = false;
  await user.save();

  const message = `Hi ${user.name},
We received a request to reset your password.
Your reset code is: ${resetCode} (valid 10 minutes).`;

  try {
    await sendEmail({
      email: user.email,
      subject: 'Your password reset code (valid for 10 min)',
      message,
    });
  } catch (err) {
    user.passwordResetCode = undefined;
    user.passwordResetExpires = undefined;
    user.passwordResetVerified = undefined;
    await user.save();
    return next(new ApiError('There is an error in sending email', 500));
  }

  res.status(200).json({ status: 'Success', message: 'Reset code sent to email' });
});

// @desc    Verify password reset code
// @route   POST /api/v1/auth/verifyResetCode
// @access  Public
exports.verifyPassResetCode = asyncHandler(async (req, res, next) => {
  const hashedResetCode = crypto
    .createHash('sha256')
    .update(String(req.body.resetCode || ''))
    .digest('hex');

  const query = {
    passwordResetCode: hashedResetCode,
    passwordResetExpires: { $gt: Date.now() },
  };
  if (req.body.email) query.email = req.body.email.toLowerCase();

  const user = await User.findOne(query);
  if (!user) return next(new ApiError('Reset code invalid or expired', 400));

  user.passwordResetVerified = true;
  await user.save();

  res.status(200).json({ status: 'Success' });
});

// @desc    Reset password
// @route   PUT /api/v1/auth/resetPassword
// @access  Public
exports.resetPassword = asyncHandler(async (req, res, next) => {
  const { email, newPassword } = req.body;

  const user = await User.findOne({ email });
  if (!user) return next(new ApiError(`There is no user with email ${email}`, 404));

  if (!user.passwordResetVerified || (user.passwordResetExpires || 0) < Date.now()) {
    return next(new ApiError('Reset code not verified or expired', 400));
  }

  user.password = newPassword;
  user.passwordResetCode = undefined;
  user.passwordResetExpires = undefined;
  user.passwordResetVerified = undefined;
  await user.save();

  const token = createToken({ id: user._id });
  res.status(200).json({ token });
});

// @desc   Verify Google ID token (mobile) → issue our JWT
// @route  POST /api/v1/auth/google    (also available at /google/verify)
// @access Public
exports.googleVerify = asyncHandler(async (req, res, next) => {
  // Accept multiple key names from different clients
  const idToken =
    req.body.id_token ||
    req.body.idToken ||
    req.body.tokenId ||
    req.body.credential;

  if (!idToken) return next(new ApiError('id_token is required', 400));

  const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

  let ticket;
  try {
    ticket = await client.verifyIdToken({
      idToken,
      audience: process.env.GOOGLE_CLIENT_ID, // must be your WEB client ID
    });
  } catch (e) {
    return next(new ApiError('Invalid Google token', 401));
  }

  const payload = ticket.getPayload();
  const googleId = payload.sub;
  const email = (payload.email || '').toLowerCase();
  const name = payload.name || (email ? email.split('@')[0] : 'Google User');
  const avatar = payload.picture;

  // Find by googleId or email
  let user = await User.findOne({ $or: [{ googleId }, { email }] });
  if (!user) {
    // create with a random password (user can set local password later)
    const randomHash = await bcrypt.hash(crypto.randomBytes(16).toString('hex'), 12);
    user = await User.create({
      name,
      email,
      password: randomHash,
      googleId,
      provider: 'google',
      profileImg: avatar,
    });
  } else {
    if (!user.googleId) user.googleId = googleId;
    if (avatar && !user.profileImg) user.profileImg = avatar;
    if (name && !user.name) user.name = name;
    if (user.provider !== 'google') user.provider = 'google';
    await user.save();
  }

  const token = createToken({ id: user._id });

  // Match the shape your Flutter client expects: { user, token }
  res.status(200).json({
    user: {
      _id: user._id,
      name: user.name,
      email: user.email,
      profileImg: user.profileImg,
      provider: user.provider,
      googleId: user.googleId,
    },
    token,
  });
});
