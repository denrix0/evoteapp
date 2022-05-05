import { Outlet, useLocation, Navigate } from "react-router-dom";
import AppBar from "./components/AppBar";

export default function App() {
  const location = useLocation().pathname;
  if (location !== "/") {
    return (
      <div>
        <AppBar />
        <Outlet />
      </div>
    );
  } else {
    return <Navigate replace to="/voting" />;
  }
}
