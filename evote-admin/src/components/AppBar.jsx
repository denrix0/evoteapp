import { useEffect, useState } from "react";
import AppBar from "@mui/material/AppBar";
import Box from "@mui/material/Box";
import Typography from "@mui/material/Typography";
import Paper from "@mui/material/Paper";
import Button from "@mui/material/Button";
import ButtonGroup from "@mui/material/ButtonGroup";
import { Link, useLocation } from "react-router-dom";
import Toolbar from "@mui/material/Toolbar";
import TextField from "@mui/material/TextField";

const ResponsiveAppBar = () => {
  const location = useLocation().pathname;
  const [userType, setUserType] = useState("");
  const [serverIp, setServerIp] = useState("");
  const server = localStorage.getItem("serverIp");

  useEffect(() => {
    const getUserType = () => {
      return fetch(server + "/")
        .then((res) => {
          if (res.ok) {
            return res.json();
          }
          throw new Error("Something went wrong");
        })
        .then((json) => {
          const tempSwap = { evote_node: "NODE", evote_owner: "OWNER" };
          setUserType(tempSwap[json.user_type]);
        })
        .catch((error) => {
          setUserType("Not Connected to a Node");
        });
    };
    getUserType();
  }, [server]);

  return (
    <AppBar position="static" sx={{ backgroundColor: "#251D3A" }}>
      <Toolbar>
        <Box
          sx={{
            display: "flex",
            flexGrow: 1,
          }}
        >
          <ButtonGroup variant="contained" sx={{ backgroundColor: "#251D3A" }}>
            {["voting", "users"].map((page) => {
              const locPage = location === "/" + page;
              return (
                <Link
                  to={locPage ? "#" : "/" + page}
                  style={{ textDecoration: "none" }}
                  key={page}
                >
                  <Button
                    key={page}
                    variant={locPage ? "outlined" : "text"}
                    size="large"
                    sx={{
                      paddingX: "1em",
                      paddingY: "0.5em",
                      my: 2,
                      display: "block",
                      marginX: "1em",
                    }}
                  >
                    <Typography textAlign="center" variant="h5">
                      {page.charAt(0).toUpperCase() + page.slice(1)}
                    </Typography>
                  </Button>
                </Link>
              );
            })}
          </ButtonGroup>
        </Box>
        <TextField
          id="options-input"
          name="options"
          multiline
          type="text"
          size="small"
          defaultValue={localStorage.getItem("serverIp")}
          onChange={(e) => setServerIp(e.target.value)}
          sx={{
            "& .MuiOutlinedInput-root": {
              backgroundColor: "white",
            },
          }}
        />
        <Button
          variant="contained"
          size="large"
          sx={{ marginX: "1em" }}
          onClick={() => localStorage.setItem("serverIp", serverIp)}
        >
          Connect
        </Button>
        <Paper elevation={12}>
          <Typography
            variant="h6"
            sx={{
              paddingY: "0.4em",
              paddingX: "2em",
              background: "transparent",
              fontWeight: "bold",
            }}
          >
            {userType}
          </Typography>
        </Paper>
      </Toolbar>
    </AppBar>
  );
};

export default ResponsiveAppBar;
