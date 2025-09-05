const mongoose = require('mongoose');
const Product = require('./models/productModel'); // adjust path
require('dotenv').config();

const products = require('./dummyProducts.json'); // the JSON above

mongoose
  .connect(process.env.MONGO_URI)
  .then(async () => {
    console.log('Connected to MongoDB');
    await Product.insertMany(products);
    console.log('Dummy products inserted!');
    process.exit();
  })
  .catch((err) => {
    console.error(err);
    process.exit(1);
  });
