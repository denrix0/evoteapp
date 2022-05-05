// import { useEffect, useState } from "react";
import { BarChart, Bar, XAxis, YAxis } from "recharts";
import Grid from "@mui/material/Grid";
import Typography from "@mui/material/Typography";
import Paper from "@mui/material/Paper";
import Stack from "@mui/material/Stack";
import CompWindow from "../components/CompWindow";
import Button from "@mui/material/Button";
import Divider from "@mui/material/Divider";

export default function VoteManagement() {
  // const [data, setData] = useState([]);

  // useEffect(() => {
  //   const fetchData = async () => {
  //     fetch("https://localhost:5000/mgmt_page")
  //       .then((res) => res.json())
  //       .then((json) => {
  //         var poll = [];

  //         Object.entries(json).map(([key, value]) => {
  //           poll.push({ name: key, votes: value });
  //         });

  //         setData(poll);
  //       });
  //   };

  //   const interv = setInterval(() => {
  //     fetchData();
  //   }, 5000);

  //   fetchData(); // <-- (2) invoke on mount

  //   return () => clearInterval(interv);
  // }, []);

  const data = [
    { name: "Option 1", votes: 50 },
    { name: "Option 2", votes: 150 },
    { name: "Option 3", votes: 30 },
    { name: "Option 4", votes: 200 },
  ];

  return (
    <Grid container>
      <Grid item xs={6}>
        <CompWindow title={"Poll Chart"}>
          <BarChart width={500} height={400} data={data}>
            <XAxis dataKey="name" />
            <YAxis />
            <Bar dataKey="votes" fill="#8884d8" />
          </BarChart>
        </CompWindow>
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
                <Typography variant="h6">Ass</Typography>
              </Paper>
            </Stack>
            <Stack direction="row" alignItems="center" justifyContent="center">
              <Button variant="contained" size="large">
                Start
              </Button>
              <Divider
                orientation="vertical"
                color="transparent"
                sx={{ paddingX: "0.5em", borderWidth: 0 }}
              />
              <Button variant="contained" size="large">
                Stop
              </Button>
            </Stack>
          </Stack>
        </CompWindow>
      </Grid>
      <Grid item xs={6}>
        <CompWindow title={"Voting Configuration"}></CompWindow>
      </Grid>
    </Grid>
  );
}
