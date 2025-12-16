const mongoose = require("mongoose");

const userSchema = new mongoose.Schema(
  {
    nome: {
      type: String,
      require: true,
      trim: true,
    },
    email: {
      type: String,
      require: true,
      lowercase: true,
    },
  },
  {
    timestamps: true,
  }
);

const User = mongoose.model("User", userSchema);
module.exports = User;
