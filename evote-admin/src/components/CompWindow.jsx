import Box from "@mui/material/Box";
import Divider from "@mui/material/Divider";
import Typography from "@mui/material/Typography";

const CompWindow = ({ title, children }) => {
  if (
    process.env.REACT_APP_SQL_USER === "owner" ||
    title === "Poll Chart" ||
    title === "Create User" ||
    title === "Delete User"
  ) {
    return (
      <Box
        sx={{
          marginTop: "2em",
          marginX: "2em",
          justifyItems: "center",
          boxShadow: "4px 4px 12px 2px rgba(0, 0, 0, 0.2)",
          borderRadius: "12px 12px 12px 12px",
        }}
      >
        <Box
          display="flex"
          justifyContent="center"
          alignItems="center"
          sx={{
            justifyItems: "center",
            padding: "0.15em",
            backgroundColor: "#251D3A",
            borderColor: "#251D3A",
            borderRadius: "12px 12px 0px 0px",
          }}
        >
          <Typography
            variant="subtitle1"
            sx={{ fontWeight: "bold", color: "white" }}
          >
            {title}
          </Typography>
        </Box>
        <Divider sx={{ backgroundColor: "#251D3A", borderBottomWidth: 2 }} />
        <Box
          display="flex"
          justifyContent="center"
          alignItems="center"
          sx={{
            padding: "1em",
            justifyItems: "center",
            borderRadius: "0px 0px 12px 12px",
          }}
        >
          {children}
        </Box>
      </Box>
    );
  }
};

export default CompWindow;
