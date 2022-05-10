import { useState } from "react";
import { Outlet, useLocation, Navigate } from "react-router-dom";
import AppBar from "./components/AppBar";

export default function App() {
  const location = useLocation().pathname;
  const [connected, setConnected] = useState(false);

  function checkServer(ipaddress) {
    fetch(ipaddress)
      .then((res) => {
        setConnected(true);
      })
      .catch((error) => {
        setConnected(false);
      });
  }

  if (location !== "/") {
    const Content = () => {
      const server = localStorage.getItem("serverIp");
      checkServer(server);
      if (connected) {
        return <Outlet />;
      } else {
        return <div>ass</div>;
      }
    };
    return (
      <div>
        <AppBar />
        <Content />
      </div>
    );
  } else {
    return <Navigate replace to="/voting" />;
  }
}
