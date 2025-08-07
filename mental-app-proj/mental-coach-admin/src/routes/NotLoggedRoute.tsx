import { Navigate, useLocation } from "react-router";
import { getAuth, signOut } from "firebase/auth";
import { ReactNode } from "react";
import { useUser } from "../hooks/useUser";
import AppLoadingScreen from "../components/general/AppLoadingScreen";
import { enqueueSnackbar } from "notistack";

type Props = {
  children: ReactNode;
};

function NotLoggedRoute({ children }: Props) {
  const { user } = useUser();
  const location = useLocation();

  const fromUrl = location.state?.from?.pathname || "/dashboard";
  console.log(user);
  // still trying to login
  if (user === undefined) {
    return <AppLoadingScreen />;
  }
  // if NOT authenticated
  if (user === null) {
    return children;
  }

  if (!user.isAdmin) {
    console.log("user not admin");
    enqueueSnackbar(`אין גישה למשתמש זה`, {
      variant: "error",
      preventDuplicate: true,
      autoHideDuration: 5000,
    });
    signOut(getAuth());
    return <Navigate to={"/"} />;
  }

  return <Navigate to={fromUrl} replace />;
}

export default NotLoggedRoute;
