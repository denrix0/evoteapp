import Box from "@mui/material/Box";

const CompWindow = ({ children }) => {
  return (
    <Box
      display="flex"
      justifyContent="center"
      alignItems="center"
      sx={{
        border: 1,
        margin: "2em",
        padding: "1em",
        justifyItems: "center",
      }}
    >
      {children}
    </Box>
  );
};

export default CompWindow;
