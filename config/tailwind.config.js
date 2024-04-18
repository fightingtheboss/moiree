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
      animation: {
        "appear-then-fade": "appear-then-fade 5s both",
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
