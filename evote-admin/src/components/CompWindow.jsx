import Box from "@mui/material/Box";
import Divider from "@mui/material/Divider";
import Typography from "@mui/material/Typography";

const CompWindow = ({ title, children }) => {
  return (
    <Box
      sx={{
        border: 1,
        marginTop: "2em",
        marginX: "2em",
        justifyItems: "center",
        borderRadius: "10px",
      }}
    >
      <Box
        display="flex"
        justifyContent="center"
        alignItems="center"
        sx={{
          justifyItems: "center",
          padding: "0.1em",
        }}
      >
        <Typography variant="subtitle1" sx={{ fontWeight: "bold" }}>
          {title}
        </Typography>
      </Box>
      <Divider sx={{ backgroundColor: "black", borderBottomWidth: 1 }} />
      <Box
        display="flex"
        justifyContent="center"
        alignItems="center"
        sx={{
          padding: "1em",
          justifyItems: "center",
        }}
      >
        {children}
      </Box>
    </Box>
  );
};

export default CompWindow;
