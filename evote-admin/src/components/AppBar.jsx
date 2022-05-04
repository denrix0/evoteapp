import * as React from "react";
import AppBar from "@mui/material/AppBar";
import Box from "@mui/material/Box";
import Toolbar from "@mui/material/Toolbar";
import Typography from "@mui/material/Typography";
import Container from "@mui/material/Container";
import Button from "@mui/material/Button";
import ButtonGroup from "@mui/material/ButtonGroup";
import { Link, useLocation } from "react-router-dom";

const ResponsiveAppBar = () => {
  const location = useLocation().pathname;

  return (
    <AppBar position="static">
      <Container maxWidth="xxl">
        <Toolbar disableGutters>
          <Box sx={{ flexGrow: 1, display: { xs: "none", md: "flex" } }}>
            <ButtonGroup disableElevation variant="text">
              {["votes", "users", "support"].map((page) => {
                const locPage = location === "/" + page;

                return (
                  <Link
                    to={"/" + (locPage ? "#" : page)}
                    style={{ textDecoration: "none" }}
                    key={page}
                  >
                    <Button
                      key={page}
                      variant={"outline"}
                      size="large"
                      sx={{ my: 2, color: "white", display: "block" }}
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

          <Box sx={{ flexGrow: 0 }}>
            <Button sx={{ my: 2, color: "white", display: "inline" }}>
              Login
            </Button>
          </Box>
        </Toolbar>
      </Container>
    </AppBar>
  );
};

export default ResponsiveAppBar;
