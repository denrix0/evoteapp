import * as React from "react";
import AppBar from "@mui/material/AppBar";
import Box from "@mui/material/Box";
import Typography from "@mui/material/Typography";
import Paper from "@mui/material/Paper";
import Button from "@mui/material/Button";
import ButtonGroup from "@mui/material/ButtonGroup";
import { Link, useLocation } from "react-router-dom";
import Toolbar from "@mui/material/Toolbar";

const ResponsiveAppBar = () => {
  const location = useLocation().pathname;
  console.log(process.env);
  const userToName = {
    evote_node: "NODE",
    evote_owner: "OWNER",
  };

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
            {["votes", "users"].map((page) => {
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
                    <Typography textAlign="center" variant="h6">
                      {page.charAt(0).toUpperCase() + page.slice(1)}
                    </Typography>
                  </Button>
                </Link>
              );
            })}
          </ButtonGroup>
        </Box>
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
            {userToName[process.env.REACT_APP_SQL_USER]}
          </Typography>
        </Paper>
      </Toolbar>
    </AppBar>
  );
};

export default ResponsiveAppBar;
