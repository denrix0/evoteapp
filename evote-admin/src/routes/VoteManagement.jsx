import { useEffect, useState } from "react";
import { BarChart, Bar, XAxis, YAxis } from "recharts";
import Grid from "@mui/material/Grid";
import Typography from "@mui/material/Typography";
import Paper from "@mui/material/Paper";
import Stack from "@mui/material/Stack";
import CompWindow from "../components/CompWindow";
import Button from "@mui/material/Button";
import Divider from "@mui/material/Divider";
import FormControl from "@mui/material/FormControl";
import FormGroup from "@mui/material/FormGroup";
import TextField from "@mui/material/TextField";

export default function VoteManagement() {
  const [voteConfig, setVoteConfig] = useState({});
  const server = localStorage.getItem("serverIp");

  const defaultValues = {
    expiry: "Loading",
    prompt: "Loading",
    options: "Loading",
  };

  const defaultData = [
    { name: "Option 1", votes: 50 },
    { name: "Option 2", votes: 150 },
    { name: "Option 3", votes: 30 },
    { name: "Option 4", votes: 200 },
    { name: "Option 5", votes: 290 },
  ];

  const [data, setData] = useState(defaultData);

  const [formValues, setFormValues] = useState(defaultValues);

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormValues({
      ...formValues,
      [name]: value,
    });
  };

  const voteConfigRequest = async (content) => {
    fetch(server + "/config", {
      method: "POST",
      headers: {
        Accept: "application/json",
        "Content-Type": "application/json",
      },
      body: JSON.stringify(content),
    })
      .then((res) => {
        if (res.ok) {
          return res.json();
        }
        throw new Error("Something went wrong");
      })
      .then((json) => {
        if (content.type === "fetch") {
          setVoteConfig(json.data);
          setFormValues({
            expiry: json.data.expiry,
            prompt: json.data.prompt,
            options: json.data.options.join("\n"),
          });
        }
      })
      .catch((error) => {
        console.error(error);
      });
  };

  const updateVoteStatus = (status) => {
    voteConfigRequest({
      type: "edit",
      data: {
        property: "ongoing",
        value: status,
      },
    });
    setTimeout(() => voteConfigRequest({ type: "fetch" }), 2000);
  };

  const setDefaults = () => {
    voteConfigRequest({ type: "reset" });
    setTimeout(() => voteConfigRequest({ type: "fetch" }), 2000);
  };

  const updateVoteConfig = () => {
    Object.entries(formValues).forEach(function ([key, value]) {
      if (key === "options") {
        value = value.split("\n");
      }
      voteConfigRequest({
        type: "edit",
        data: {
          property: key,
          value: value,
        },
      });
    });
    setTimeout(() => voteConfigRequest({ type: "fetch" }), 2000);
  };

  useEffect(() => {
    voteConfigRequest({ type: "fetch" });

    const fetchData = async () => {
      fetch(server + "/vote_status")
        .then((res) => {
          if (res.ok) {
            return res.json();
          }
          throw new Error("Something went wrong");
        })
        .then((json) => {
          var poll = [];

          Object.entries(json).forEach(([key, value]) => {
            poll.push({
              name: key,
              votes: value + defaultData[poll.length].votes,
            });
          });

          setData(poll);
        })
        .catch((error) => {
          console.error(error);
        });
    };

    const interv = setInterval(() => {
      fetchData();
    }, 5000);

    fetchData();

    return () => clearInterval(interv);
  }, [server]);

  //TODO: Set chart to normal Options

  return (
    <Grid container>
      <Grid item>
        <CompWindow title={"Poll Chart"}>
          <BarChart
            width={data.length * 130}
            height={600}
            data={data}
            margin={{ top: 50, left: 0, bottom: 10, right: 50 }}
          >
            <XAxis dataKey="name" />
            <YAxis />
            <Bar
              dataKey="votes"
              barSize={80}
              fill="#98D6EA"
              stroke="#000000"
              strokeWidth={1}
              label
            />
          </BarChart>
        </CompWindow>
      </Grid>
      <Grid item>
        <CompWindow title={"Vote Control"}>
          <Stack
            direction="row"
            justifyContent="space-between"
            alignItems="center"
          >
            <Stack direction="row" alignItems="center" justifyContent="center">
              <Typography variant="h6">Vote Status</Typography>
              <Paper
                elevation={1}
                sx={{ marginX: "1em", paddingY: "0.4em", paddingX: "2em" }}
              >
                <Typography variant="h6">
                  {voteConfig !== {}
                    ? voteConfig.ongoing === "1"
                      ? "Running"
                      : "Stopped"
                    : "Loading"}
                </Typography>
              </Paper>
            </Stack>
            <Stack direction="row" alignItems="center" justifyContent="center">
              <Button
                variant="contained"
                size="large"
                onClick={() => updateVoteStatus("1")}
              >
                Start
              </Button>
              <Divider
                orientation="vertical"
                color="transparent"
                sx={{ paddingX: "0.5em", borderWidth: 0 }}
              />
              <Button
                variant="contained"
                size="large"
                onClick={() => updateVoteStatus("0")}
              >
                Stop
              </Button>
            </Stack>
          </Stack>
        </CompWindow>
        <CompWindow title={"Voting Configuration"}>
          <Stack orientation="column" width={500}>
            <FormControl>
              <FormGroup>
                <TextField
                  id="expiry-input"
                  name="expiry"
                  label="Expiry"
                  type="text"
                  value={formValues.expiry}
                  onChange={handleInputChange}
                  sx={{
                    marginX: "1em",
                    marginY: "0.5em",
                  }}
                />
                <FormGroup>
                  <TextField
                    id="prompt-input"
                    name="prompt"
                    label="Prompt"
                    type="text"
                    multiline
                    rows={2}
                    value={formValues.prompt}
                    onChange={handleInputChange}
                    sx={{
                      marginX: "1em",
                      marginY: "0.5em",
                    }}
                  />
                  <TextField
                    id="options-input"
                    name="options"
                    label="Options"
                    multiline
                    rows={6}
                    type="text"
                    value={formValues.options}
                    onChange={handleInputChange}
                    sx={{
                      marginX: "1em",
                      marginY: "0.5em",
                    }}
                  />
                </FormGroup>
              </FormGroup>
            </FormControl>
            <Button
              size="large"
              variant="contained"
              sx={{ margin: "1em" }}
              onClick={() => updateVoteConfig()}
            >
              Update
            </Button>
            <Button
              size="large"
              variant="contained"
              sx={{ margin: "1em" }}
              onClick={() => setDefaults()}
            >
              Reset Settings
            </Button>
          </Stack>
        </CompWindow>
      </Grid>
    </Grid>
  );
}
