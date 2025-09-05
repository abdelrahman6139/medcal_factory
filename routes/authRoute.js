// routes/authRoutes.js
const express = require('express');
const {
  signupValidator,
  loginValidator,
} = require('../utils/validators/authValidator');

const {
  signup,
  login,
  forgotPassword,
  verifyPassResetCode,
  resetPassword,
  googleVerify,
} = require('../services/authService');

const router = express.Router();

router.post('/signup', signupValidator, signup);
router.post('/login', loginValidator, login);
router.post('/forgotPassword', forgotPassword);
router.post('/verifyResetCode', verifyPassResetCode);
router.put('/resetPassword', resetPassword);

// IMPORTANT: expose /google to match the mobile app
router.post('/google', googleVerify);

// If you still want the old path to work too, keep this:
//router.post('/google/verify', googleVerify);

module.exports = router;
