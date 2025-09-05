const path = require('path');

// 1) Load env FIRST and from the folder this file lives in
require('dotenv').config({ path: path.join(__dirname, '.env') });

// 2) Guard: fail fast if critical envs are missing
const requiredEnv = ['JWT_SECRET', 'MONGO_URI'];
const missing = requiredEnv.filter(
  (k) => !process.env[k] || String(process.env[k]).trim() === ''
);
if (missing.length) {
  throw new Error(`Missing required env vars: ${missing.join(', ')}`);
}

const express = require('express');
const morgan = require('morgan');
const cors = require('cors');
const compression = require('compression');
const rateLimit = require('express-rate-limit');
const hpp = require('hpp');

const ApiError = require('./utils/apiError');
const globalError = require('./middlewares/errorMiddleware');
const dbConnection = require('./config/database');

// Routes
const mountRoutes = require('./routes');
const authRouter = require('./routes/authRoute');
//app.use('/api/v1/auth', authRouter);
const { webhookCheckout } = require('./services/orderService');

// 3) Connect DB (now env is guaranteed loaded)
dbConnection();

const app = express();

// Enable other domains to access your application
app.use(cors());
app.options('*', cors());

// compress all responses
app.use(compression());

// Stripe (or similar) webhook must come BEFORE express.json()
app.post(
  '/webhook-checkout',
  express.raw({ type: 'application/json' }),
  webhookCheckout
);

// JSON/body parser (after webhook)
app.use(express.json({ limit: '20kb' }));
app.use(express.static(path.join(__dirname, 'uploads')));

if (process.env.NODE_ENV === 'development') {
  app.use(morgan('dev'));
  console.log(`mode: ${process.env.NODE_ENV}`);
}

// Rate limit (covers /api and all children such as /api/v1/…)
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100,
  message: 'Too many requests from this IP, please try again later.',
});
app.use('/api', limiter);

// Protect against HTTP Parameter Pollution
app.use(
  hpp({
    whitelist: ['price', 'sold', 'quantity', 'ratingsAverage', 'ratingsQuantity'],
  })
);

// Mount Routes
app.use('/api/v1/auth', authRouter); // <-- auth routes mounted correctly
mountRoutes(app); // <-- your other route groups

// 404 handler
app.all('*', (req, res, next) => {
  next(new ApiError(`Can't find this route: ${req.originalUrl}`, 404));
});

// Global error handler
app.use(globalError);

// Start server
const PORT = process.env.PORT || 8000;
const server = app.listen(PORT, () => {
  console.log(`App running on http://localhost:${PORT}`);
});

// Unhandled promise rejections
process.on('unhandledRejection', (err) => {
  console.error(`UnhandledRejection: ${err.name} | ${err.message}`);
  server.close(() => {
    console.error('Shutting down…');
    process.exit(1);
  });
});
