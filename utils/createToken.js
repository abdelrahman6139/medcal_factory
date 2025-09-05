// Backward-compat wrapper so older code calling `createToken(...)` keeps working.
const jwt = require('jsonwebtoken');

function createToken(userIdOrPayload) {
  const payload = typeof userIdOrPayload === 'object'
    ? userIdOrPayload
    : { id: userIdOrPayload };

  const expiresIn =
    process.env.ACCESS_TOKEN_EXPIRES_IN ||
    process.env.JWT_EXPIRES_IN ||
    '30d';

  if (!process.env.JWT_SECRET) {
    throw new Error('JWT_SECRET is missing (check your .env)');
  }

  return jwt.sign(payload, process.env.JWT_SECRET, { expiresIn });
}

module.exports = createToken; // <-- export a FUNCTION
