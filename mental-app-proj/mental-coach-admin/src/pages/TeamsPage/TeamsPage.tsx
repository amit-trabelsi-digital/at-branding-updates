import { IconButton, Tooltip } from "@mui/material";
import { enqueueSnackbar } from "notistack";
import useSWR from "swr";
import { appFetch } from "../../services/fetch";
import { DataGrid, GridColDef, GridToolbar } from "@mui/x-data-grid";
import { Team } from "../../utils/types";
import useDialog from "../../hooks/useDialog";
import { useState } from "react";
import TeamDialog from "../../components/dialogs/TeamDialog";
import EditIcon from "@mui/icons-material/Edit";
import DeleteIcon from "@mui/icons-material/Delete";
import AppTitle from "../../components/general/AppTitle";
import AppFab from "../../components/general/AppFab";
import AppColorBall from "../../components/general/AppColorBall";
import { deleteItem, simpleDateFormatter } from "../../utils/tools";
import { useConfirm } from "material-ui-confirm";

export default function TeamPage() {
  const baseUrl = "/api/teams";
  const { data: teams, mutate } = useSWR("/api/teams");

  const [selectedTeam, setSelectedTeam] = useState<Team | null>(null);
  const confirm = useConfirm();

  console.log(teams);
  const {
    open: isTeamDialogOpen,
    closeDialog: onCloseTeamDialog,
    openDialog: onOpenTeamDialog,
  } = useDialog({ initialOpen: false, setItem: setSelectedTeam });

  const columns = [
    {
      field: "name",
      headerName: " שם הקבוצה",
      minWidth: 200,
    },
    {
      field: "city",
      headerName: "שם העיר",
      minWidth: 160,
    },
    {
      field: "hex1",
      headerName: "צבע ראשי",
      renderCell: (params: { row: Team }) => {
        return (
          <div
            style={{
              paddingTop: 8,
            }}
          >
            <AppColorBall hexColor={params.row.hex1} />
          </div>
        );
      },
      width: 70,
    },
    {
      field: "hex2",
      headerName: "צבע משני",
      renderCell: (params: { row: Team }) => {
        return (
          <div
            style={{
              paddingTop: 8,
            }}
          >
            <AppColorBall hexColor={params.row.hex2} size="medium" />
          </div>
        );
      },
      width: 70,
    },
    {
      field: "hex3",
      headerName: "צבע שלישי",
      renderCell: (params: { row: Team }) => {
        return (
          <div
            style={{
              paddingTop: 8,
            }}
          >
            <AppColorBall hexColor={params.row.hex3} size="small" />
          </div>
        );
      },
      width: 80,
    },

    {
      field: "updatedAt",
      headerName: "עודכן בתאריך",
      minWidth: 100,
      renderCell: (params: { row: Team }) => (
        <div>{simpleDateFormatter(params.row.updatedAt)}</div>
      ),
    },
    {
      field: "actions",
      type: "actions",
      minWidth: 50,
      cellClassName: "actions",
      sortable: false,
      getActions: ({ row }: { row: Team }) => [
        <Tooltip key={`edit-btn-${row._id}`} title="עריכה">
          <div style={{ minWidth: "40px" }}>
            <IconButton
              color="secondary"
              onClick={async () => {
                onOpenTeamDialog(row);
              }}
            >
              <EditIcon />
            </IconButton>
          </div>
        </Tooltip>,
        <Tooltip key={`delete-btn-${row._id}`} title="מחיקה">
          <IconButton
            onClick={async () => {
              await confirm({ description: `למחוק '${row.name}'?` });
              deleteItem(row, baseUrl, onSuccess, onError);
            }}
            key={`delete-btn-${row._id}`}
          >
            <DeleteIcon />
          </IconButton>
        </Tooltip>,
      ],
    },
  ];

  const onSuccess = (message = "Changes saved") => {
    enqueueSnackbar(message);
    mutate();
  };

  type Error = {
    message: string;
  };
  const onError = (err: Error) => {
    console.error(err);
    enqueueSnackbar(err.message || "Error", { variant: "error" });
  };

  async function processRowUpdate(newRow: Team) {
    const dataToUpdate = newRow;
    try {
      const res = await appFetch(`${baseUrl}/${newRow._id}`, {
        method: "PUT",
        body: JSON.stringify(dataToUpdate),
      });
      if (!res.ok) throw new Error();
      onSuccess();
      const resData = await res.json();
      return resData;
    } catch (err) {
      onError(err as { message: string });
    }
  }

  return (
    <div>
      <AppTitle title="קבוצות" />
      <DataGrid
        sx={{ marginTop: 10 }}
        rows={teams || []}
        onProcessRowUpdateError={onError}
        processRowUpdate={processRowUpdate}
        columns={columns as GridColDef<Team>[]}
        getRowId={(row: Partial<Team>) => row._id as string}
        initialState={{
          sorting: {
            sortModel: [{ field: "createdAt", sort: "desc" }],
          },
        }}
        slots={{
          toolbar: () => <GridToolbar showQuickFilter />,
        }}
        loading={!teams}
      />

      <AppFab text="הוסף קבוצה" DialogTrigger={onOpenTeamDialog} />
      <TeamDialog
        open={isTeamDialogOpen}
        onClose={onCloseTeamDialog}
        selectedItem={selectedTeam}
      />
    </div>
  );
}
