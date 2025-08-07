import { createTheme, ThemeProvider } from "@mui/material";
import { palette } from "./mui-palette";
import { ReactNode } from "react";
// import { heIL } from "@mui/x-data-grid";
import { heIL as coreHeIl } from "@mui/material/locale";
import { heIL } from "@mui/x-data-grid/locales";
const theme = createTheme(
  {
    palette: palette,

    typography: {
      fontFamily: "Assistant ",
      h1: {
        fontSize: "2.4rem",
        "@media (max-width:600px)": {
          fontSize: "1.7rem",
        },
      },
      h2: {
        fontSize: "1.5rem",
        fontWeight: 500,
        "@media (max-width:600px)": {
          fontSize: "1.2rem",
        },
      },
      h3: {
        fontSize: "1.4rem",
      },
      h4: {
        fontSize: "1.2rem",
      },
    },
    components: {
      // MuiDialog: {
      //   styleOverrides: { root: { maxWidth: "50dvw" } },
      // },
      MuiDialogTitle: {
        styleOverrides: {
          root: {
            lineHeight: 0,
          },
        },
      },
      MuiCard: {
        styleOverrides: { root: { borderRadius: 25 } },
        defaultProps: { elevation: 3 },
      },
      MuiLink: { defaultProps: { underline: "hover" } },
    },
  },
  heIL,
  coreHeIl
);

type Props = { children: ReactNode };

export const CustomThemeProvider = ({ children }: Props) => (
  <ThemeProvider theme={theme}>{children}</ThemeProvider>
);
