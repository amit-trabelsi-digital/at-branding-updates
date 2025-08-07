import { IconButton, Tooltip } from "@mui/material";
import { enqueueSnackbar } from "notistack";
import useSWR from "swr";
import { appFetch } from "../../services/fetch";
import { DataGrid, GridColDef, GridToolbar } from "@mui/x-data-grid";
import { League } from "../../utils/types";
import useDialog from "../../hooks/useDialog";
import { useState } from "react";
import LeagueDialog from "../../components/dialogs/LeagueDialog";
import { deleteItem, localHebrewDateFormmater } from "../../utils/tools";
import EditIcon from "@mui/icons-material/Edit";
import AppTitle from "../../components/general/AppTitle";
import AppFab from "../../components/general/AppFab";
import DeleteIcon from "@mui/icons-material/Delete";
import { useConfirm } from "material-ui-confirm";

export default function LeaguePage() {
  const baseUrl = "/api/leagues";
  const { data: leagues, mutate } = useSWR("/api/leagues");

  const [selectedLeague, setSelectedLeague] = useState<League | null>(null);
  const confirm = useConfirm();

  const {
    open: isLeagueDialogOpen,
    closeDialog: onCloseLeagueDialog,
    openDialog: onOpenLeagueDialog,
  } = useDialog({ initialOpen: false, setItem: setSelectedLeague });

  const columns = [
    {
      field: "name",
      headerName: " שם הליגה",
      minWidth: 200,
    },
    {
      field: "country",
      headerName: "מדינה",
      minWidth: 160,
      renderCell: (params: { row: League }) => <div>{params.row.country}</div>,
    },
    {
      field: "season",
      headerName: "עונה",
      minWidth: 60,
      renderCell: (params: { row: League }) => <div>{params.row.season}</div>,
    },
    {
      field: "numberOfTeams",
      headerName: "מס קבוצות",
      minWidth: 200,
      renderCell: (params: { row: League }) => (
        <div>{params.row.teams.length}</div>
      ),
    },
    {
      field: "createdAt",
      headerName: "נוצר ב- ",
      minWidth: 200,
      renderCell: (params: { row: League }) => (
        <div>{localHebrewDateFormmater(params.row.createdAt)}</div>
      ),
    },
    {
      field: "actions",
      type: "actions",
      minWidth: 50,
      cellClassName: "actions",
      sortable: false,
      getActions: ({ row }: { row: League }) => [
        <Tooltip key={`edit-btn-${row._id}`} title="עריכה">
          <div style={{ minWidth: "40px" }}>
            <IconButton
              color="secondary"
              onClick={async () => {
                onOpenLeagueDialog(row);
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

  async function processRowUpdate(newRow: League) {
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
      <AppTitle title={"ליגות"} />

      <DataGrid
        sx={{ marginTop: 10 }}
        rows={leagues || []}
        onProcessRowUpdateError={onError}
        processRowUpdate={processRowUpdate}
        columns={columns as GridColDef<League>[]}
        getRowId={(row: Partial<League>) => row._id as string}
        initialState={{
          sorting: {
            sortModel: [{ field: "createdAt", sort: "desc" }],
          },
        }}
        slots={{
          toolbar: () => <GridToolbar showQuickFilter />,
        }}
        loading={!leagues}
      />

      <AppFab text="הוסף ליגה" DialogTrigger={onOpenLeagueDialog} />
      <LeagueDialog
        open={isLeagueDialogOpen}
        onClose={onCloseLeagueDialog}
        selectedItem={selectedLeague}
      />
    </div>
  );
}
