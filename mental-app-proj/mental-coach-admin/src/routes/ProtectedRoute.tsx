import { Navigate, Outlet, useLocation } from "react-router-dom";
import { useUser } from "../hooks/useUser";
import AppLoadingScreen from "../components/general/AppLoadingScreen";
import Layout from "../layouts/Layout";

const ProtectedRoute = () => {
  const { user, isLoading } = useUser();
  const location = useLocation();

  if (isLoading) {
    return <AppLoadingScreen />;
  }

  if (user?.isAdmin) {
    return (
      <Layout>
        <Outlet />
      </Layout>
    );
  }

  // if NOT authenticated - back to login
  return <Navigate to="/" state={{ from: location }} replace />;
};

export default ProtectedRoute;
