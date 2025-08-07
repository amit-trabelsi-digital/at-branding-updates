import { createRoot } from "react-dom/client";
import "./index.css";
import App from "./App.tsx";
import { SnackbarProvider } from "notistack";
import { SWRConfig } from "swr";
import { UserProvider } from "./hooks/useUser.tsx";
import { appFetch } from "./services/fetch.ts";
import { StrictMode } from "react";
import { CustomThemeProvider } from "./plugins/mui.tsx";
import { ConfirmProvider } from "material-ui-confirm";
import { CacheProvider } from "@emotion/react";
import createCache from "@emotion/cache";
import { prefixer } from "stylis";
import rtlPlugin from "stylis-plugin-rtl";

// Create rtl cache
const cacheRtl = createCache({
  key: "muirtl",
  stylisPlugins: [prefixer, rtlPlugin],
});

createRoot(document.getElementById("root")!).render(
  <StrictMode>
    <CustomThemeProvider>
      <ConfirmProvider
        defaultOptions={{
          title: "האם אתה בטוח",
          confirmationText: "אישור",
          cancellationText: "ביטול",
        }}
      >
        <CacheProvider value={cacheRtl}>
          <SnackbarProvider
            autoHideDuration={3000}
            iconVariant={{ error: "" }}
            variant="success"
            disableWindowBlurListener
          >
            <SWRConfig
              value={{
                fetcher: (url) => appFetch(url).then((res) => res.json()),
              }}
            >
              <UserProvider>
                <App />
              </UserProvider>
            </SWRConfig>
          </SnackbarProvider>
        </CacheProvider>
      </ConfirmProvider>
    </CustomThemeProvider>
  </StrictMode>
);
