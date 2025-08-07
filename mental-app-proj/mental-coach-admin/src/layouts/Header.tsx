import { Typography, Button, Toolbar, AppBar } from "@mui/material";
import { getAuth } from "firebase/auth";
import { useLocation } from "react-router-dom";
import { adminRoutes, drawerWidth } from "../data/config";
import LogoutIcon from "@mui/icons-material/Logout";
const Header = () => {
  const { pathname } = useLocation();

  const appBarTitle = adminRoutes.find(
    ({ href }: { href: string }) => pathname === href
  )?.title;

  const AppBarIcon = adminRoutes.find(
    ({ href }: { href: string }) => pathname === href
  )?.Icon;

  return (
    <AppBar position="fixed">
      <Toolbar
        sx={{
          display: "flex",
          alignItems: "center",
          zIndex: 10,
          ml: drawerWidth + "px",
        }}
      >
        <Typography
          variant="h2"
          mr="auto"
          sx={{ display: "flex", gap: 1, justifyItems: "center" }}
        >
          {AppBarIcon && <AppBarIcon />}
          {appBarTitle}
        </Typography>
        <Button
          variant="outlined"
          color={"secondary"}
          onClick={() => {
            getAuth().signOut();
          }}
        >
          <Typography
            fontWeight={710}
            textTransform={"none"}
            sx={{ display: "flex", gap: 1 }}
          >
            <LogoutIcon />
            התנתק
          </Typography>
        </Button>
      </Toolbar>
    </AppBar>
  );
};

export default Header;
