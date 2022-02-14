module.exports = {
  mode: "jit",
  content: ["./js/**/*.js", "../lib/*_web/**/*.*ex"],
  theme: {
    extend: {
      colors: {
        yellow: {
          100: "#FFFDEE",
        },
        green: {
          100: "#EEFFEE",
        },
      },
    },
  },
  variants: {
    extend: {},
  },
  plugins: [],
};
