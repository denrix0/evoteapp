import { useState } from "react";
import Grid from "@mui/material/Grid";
import CompWindow from "../components/CompWindow";
import Button from "@mui/material/Button";
import FormControl from "@mui/material/FormControl";
import TextField from "@mui/material/TextField";
import InputAdornment from "@mui/material/InputAdornment";
import IconButton from "@mui/material/IconButton";
import Visibility from "@mui/icons-material/Visibility";
import VisibilityOff from "@mui/icons-material/VisibilityOff";
import Typography from "@mui/material/Typography";
import Stack from "@mui/material/Stack";
import QRCode from "react-qr-code";
import Divider from "@mui/material/Divider";

export default function UserPage() {
  const [delId, setDelId] = useState("");
  const [showPassword, setShow] = useState(false);
  const server = localStorage.getItem("serverIp");

  const randomBase32 = () => {
    const charArry = "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567".split("");
    var secret = "";
    for (var i = 0; i < 32; i++)
      secret += charArry[Math.floor(Math.random() * charArry.length)];

    return secret;
  };

  const defaultValues = {
    id: "",
    pin: "",
    totp1: randomBase32(),
    totp2: randomBase32(),
  };

  const [formValues, setFormValues] = useState(defaultValues);

  const uriString = (secret) =>
    `otpauth://totp/EVOTEAPP:Account?secret=${secret}&issuer=EVOTEAPP`;

  const voteUserRequest = async (content) => {
    fetch(server + "/users", {
      method: "POST",
      headers: {
        Accept: "application/json",
        "Content-Type": "application/json",
      },
      body: JSON.stringify(content),
    }).catch((error) => {
      console.error(error);
    });
  };

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormValues({
      ...formValues,
      [name]: value,
    });
  };

  return (
    <Grid container>
      <Grid item>
        <CompWindow title="Create User">
          <FormControl>
            <TextField
              id="id-input"
              name="id"
              label="ID"
              type="text"
              value={formValues.id}
              onChange={handleInputChange}
              sx={{
                marginX: "1em",
                marginY: "0.5em",
              }}
            />
            <TextField
              id="pin-input"
              name="pin"
              label="PIN"
              type={showPassword ? "text" : "password"}
              value={formValues.pin}
              onChange={handleInputChange}
              InputProps={{
                endAdornment: (
                  <InputAdornment position="end">
                    <IconButton onClick={() => setShow(!showPassword)}>
                      {showPassword ? <VisibilityOff /> : <Visibility />}
                    </IconButton>
                  </InputAdornment>
                ),
              }}
              sx={{
                marginX: "1em",
                marginY: "0.5em",
              }}
            />
            <Stack direction="row" sx={{ margin: "1em" }}>
              <Grid
                container
                direction="column"
                alignItems="center"
                justifyContent="center"
              >
                <Typography variant="h6">OTP 1</Typography>
                <TextField value={formValues.totp1} sx={{ margin: "1em" }} />
                <QRCode value={uriString(formValues.totp1)} />
              </Grid>
              <Divider
                variant="middle"
                orientation="vertical"
                sx={{
                  margin: "1em",
                }}
              />
              <Grid
                container
                direction="column"
                alignItems="center"
                justifyContent="center"
              >
                <Typography variant="h6">OTP 2</Typography>
                <TextField value={formValues.totp2} sx={{ margin: "1em" }} />
                <QRCode value={uriString(formValues.totp2)} />
              </Grid>
            </Stack>
            <Grid container direction={"column"}>
              <Button
                size="large"
                variant="contained"
                sx={{ margin: "1em" }}
                onClick={() => {
                  setFormValues({
                    ...formValues,
                    totp1: randomBase32(),
                    totp2: randomBase32(),
                  });
                }}
              >
                Generate QR
              </Button>
              <Button
                size="large"
                variant="contained"
                sx={{ margin: "1em" }}
                onClick={() => {
                  if (!Object.values(formValues).includes(""))
                    voteUserRequest({ type: "add", data: formValues });
                }}
              >
                Add User
              </Button>
            </Grid>
          </FormControl>
        </CompWindow>
      </Grid>
      <Grid item>
        <CompWindow title="Delete User">
          <TextField
            id="del-id-input"
            name="del-id"
            label="ID"
            type="text"
            value={delId}
            onChange={(event) => setDelId(event.target.value)}
            sx={{
              marginX: "1em",
              marginY: "0.5em",
            }}
          />
          <Button
            size="large"
            variant="contained"
            sx={{ margin: "1em", backgroundColor: "red" }}
            onClick={() =>
              voteUserRequest({ type: "delete", data: { id: delId } })
            }
          >
            Delete
          </Button>
        </CompWindow>
      </Grid>
    </Grid>
  );
}
