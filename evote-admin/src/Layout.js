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
  constructor(props) {
    super(props);
    this.page = Pages.VoteMgmt;
    this.setPage = this.setPage.bind(this);
  }

  setPage(page) {
    this.page = page;
  }

  render() {
    return (
      <div className="Layout">
        <AppBar setPage={this.setPage} />
        <div>{this.page[1]}</div>
      </div>
    );
  }
}

export default Layout;
