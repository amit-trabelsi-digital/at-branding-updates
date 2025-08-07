import { Box } from "@mui/material";
import { ScrollRestoration } from "react-router-dom";
import { palette } from "../plugins/mui-palette";
import Header from "./Header";
import Footer from "./Footer";
import AppDrawer from "./AppDrawer";
import { drawerWidth } from "../data/config";
import { ReactNode, useState, useEffect } from "react";
import SupportDialog from "../components/dialogs/SupportDialog";

type Props = {
  children: ReactNode;
};

const Layout = ({ children }: Props) => {
  const [supportDialogOpen, setSupportDialogOpen] = useState(false);
  const [openDialogName, setOpenDialogName] = useState<string | undefined>();

  useEffect(() => {
    const handleOpenSupport = () => {
      // בדיקה אם יש דיאלוג פתוח כרגע
      const activeDialog = document.querySelector('[role="dialog"]');
      if (activeDialog) {
        const dialogTitle = activeDialog.querySelector('[id*="dialog-title"], h2')?.textContent;
        setOpenDialogName(dialogTitle || 'דיאלוג לא מזוהה');
      }
      setSupportDialogOpen(true);
    };

    window.addEventListener('openSupportDialog' as any, handleOpenSupport);
    return () => {
      window.removeEventListener('openSupportDialog' as any, handleOpenSupport);
    };
  }, []);

  return (
    <Box
      bgcolor={palette.background.default}
      minHeight={"100vh"}
      display={"flex"}
      flexDirection={"column"}
      justifyContent={"space-between"}
    >
      <ScrollRestoration />
      <Box sx={{ mt: { xs: "55px", md: "75px" }, ml: drawerWidth + "px" }}>
        <Header />
        <Box px={3}>{children}</Box>
      </Box>
      <AppDrawer />
      <Footer />
      <SupportDialog 
        open={supportDialogOpen} 
        onClose={() => {
          setSupportDialogOpen(false);
          setOpenDialogName(undefined);
        }}
        openDialog={openDialogName}
      />
    </Box>
  );
};

export default Layout;
