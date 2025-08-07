import { router } from "./router";
import { RouterProvider } from "react-router-dom";
import EnvironmentIndicator from "./components/general/EnvironmentIndicator";
import React from "react";

const App = () => {
  return (
    <React.Fragment>
      <RouterProvider router={router} />
      <EnvironmentIndicator />
    </React.Fragment>
  );
};

export default App;
