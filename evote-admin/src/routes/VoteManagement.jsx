// import { useEffect, useState } from "react";
import { BarChart, Bar, XAxis, YAxis } from "recharts";
import Grid from "@mui/material/Grid";
import CompWindow from "../components/CompWindow";

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
        <CompWindow title={"Ongoing Poll"}>
          <BarChart width={500} height={400} data={data}>
            <XAxis dataKey="name" />
            <YAxis />
            <Bar dataKey="votes" fill="#8884d8" />
          </BarChart>
        </CompWindow>
      </Grid>
      <Grid item xs={6}>
        <CompWindow title={"Voting Configuration"}></CompWindow>
      </Grid>
    </Grid>
  );
}
