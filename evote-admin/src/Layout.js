import { Component } from "react";
import AppBar from "./components/AppBar";
import VoteManagement from "./pages/VoteManagement";
import UserPage from "./pages/UserPage";
import SupportPage from "./pages/SupportPage";
import "./styles/Layout.css";

export const Pages = {
  VoteMgmt: ["Vote Management", <VoteManagement />],
  UserView: ["Users", <UserPage />],
  Support: ["Support", <SupportPage />],
};

class Layout extends Component {
  setPage(page) {
    this.page = page;
  }

  constructor(props) {
    super(props);
    this.page = Pages.VoteMgmt;
  }

  render() {
    console.log(this.page);
    return (
      <div className="Layout">
        <AppBar setPage={this.setPage} />
        <div>{this.page[1]}</div>
      </div>
    );
  }
}

export default Layout;
