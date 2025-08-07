import { createBrowserRouter } from "react-router-dom";
import DashboardPage from "./pages/DashboardPage.tsx";
import LoginPage from "./pages/LoginPage.tsx";
import ProtectedRoute from "./routes/ProtectedRoute";
import NotLoggedRoute from "./routes/NotLoggedRoute";
import UsersPage from "./pages/UsersPage/UsersPage.tsx";
import MatchesPage from "./pages/MatcesPage/MatchesPage.tsx";
import TeamsPage from "./pages/TeamsPage/TeamsPage.tsx";
import SettingsPage from "./pages/SettingsPage/SettingsPage.tsx";
import LeaguesPage from "./pages/LeaguesPage/LeaguesPage.tsx";
import CaseAndReactionsPage from "./pages/CaseAndReactionsPage/CaseAndReactionsPage.tsx";
import EitanMessagesPage from "./pages/EitanMessagesPage/EitanMessagesPage.tsx";
import GoalsPage from "./pages/GoalsPage/GoalsPage.tsx";
import PushMessagesPage from "./pages/PushMessagesPage/PushMessagesPage.tsx";
import ActionsPage from "./pages/ActionsPage/ActionsPage.tsx";
import TagsPage from "./pages/TagsPage/TagsPage.tsx";
import ScorePerActionPage from "./pages/ScorePerActionPage/ScorePerActionPage.tsx";
import PersonallityGroupsPage from "./pages/PersonallityGroupsPage/PersonallityGroupsPage.tsx";
import GeneralMediaPage from "./pages/GeneralMediaPage/GeneralMediaPage.tsx";
import { TrainingProgramsPage } from "./pages/TrainingProgramsPage/TrainingProgramsPage.tsx";
import { TrainingProgramDetailsPage } from "./pages/TrainingProgramsPage/TrainingProgramDetailsPage.tsx";

export const router = createBrowserRouter([
  {
    path: "/",
    element: (
      <NotLoggedRoute>
        <LoginPage />
      </NotLoggedRoute>
    ),
  },
  {
    path: "/dashboard",
    element: <ProtectedRoute />,
    children: [
      { index: true, element: <DashboardPage /> },
      { path: "users", element: <UsersPage /> },
      { path: "matches", element: <MatchesPage /> },
      { path: "teams", element: <TeamsPage /> },
      { path: "settings", element: <SettingsPage /> },
      { path: "push-messages", element: <PushMessagesPage /> },
      { path: "goals", element: <GoalsPage /> },
      { path: "leagues", element: <LeaguesPage /> },
      { path: "eitan-messages", element: <EitanMessagesPage /> },
      { path: "case-and-reactions", element: <CaseAndReactionsPage /> },
      { path: "actions", element: <ActionsPage /> },
      { path: "scores", element: <ScorePerActionPage /> },
      { path: "personallity-group", element: <PersonallityGroupsPage /> },
      { path: "tags", element: <TagsPage /> },
      { path: "general-media", element: <GeneralMediaPage /> },
      { path: "training-programs", element: <TrainingProgramsPage /> },
      { path: "training-programs/:id", element: <TrainingProgramDetailsPage /> },
    ],
  },
]);
