const defaultTheme = require("tailwindcss/defaultTheme");

module.exports = {
  content: [
    "./public/*.html",
    "./app/helpers/**/*.rb",
    "./app/javascript/**/*.js",
    "./app/views/**/*.{erb,haml,html,slim}",
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: [
          ["Inter var", ...defaultTheme.fontFamily.sans],
          { fontFeatureSettings: '"zero" 1, "ss01" 1, "ss08" 1' },
        ],
      },
      backgroundImage: {
        "logo-radial-gradient":
          "repeating-radial-gradient(circle at 46% 45%, #fff, #777 0.05rem, #fff 0.4rem)",
        "logo-radial-gradient-overlay":
          "repeating-radial-gradient(circle at 46% 45%, #4f46e5, #fff 0.1em, #4f46e5 0.3em)",
      },
      animation: {
        "appear-then-fade": "appear-then-fade 7s both",
      },
      keyframes: {
        "appear-then-fade": {
          "0%, 100%": {
            opacity: 0,
          },
          "5%, 60%": {
            opacity: 1,
          },
        },
      },
    },
  },
  plugins: [
    require("@tailwindcss/forms"),
    require("@tailwindcss/aspect-ratio"),
    require("@tailwindcss/typography"),
    require("@tailwindcss/container-queries"),
  ],
};
