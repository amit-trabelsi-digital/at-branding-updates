import { IconButton, Tooltip } from "@mui/material";
import { enqueueSnackbar } from "notistack";
import useSWR from "swr";
import { appFetch } from "../../services/fetch";
import { DataGrid, GridColDef, GridToolbar } from "@mui/x-data-grid";
import { Match } from "../../utils/types";
import useDialog from "../../hooks/useDialog";
import { useState } from "react";
import MatchDialog from "../../components/dialogs/MatchDialog";
import { deleteItem, localHebrewDateFormmater } from "../../utils/tools";
import EditIcon from "@mui/icons-material/Edit";
import AppTitle from "../../components/general/AppTitle";
import AppFab from "../../components/general/AppFab";
import DeleteIcon from "@mui/icons-material/Delete";
import { useConfirm } from "material-ui-confirm";

export default function MatchPage() {
  const baseUrl = "/api/matches";
  const { data: matches, mutate } = useSWR(baseUrl);

  const [selectedMatch, setSelectedMatch] = useState<Match | null>(null);
  const confirm = useConfirm();

  const {
    open: isMatchDialogOpen,
    closeDialog: onCloseMatchDialog,
    openDialog: onOpenMatchDialog,
  } = useDialog({ initialOpen: false, setItem: setSelectedMatch });

  const columns = [
    {
      field: "homeTeam",
      headerName: "קבוצה מארחת",
      minWidth: 200,
      renderCell: (params: { row: Match }) => (
        <div>
          {typeof params.row.homeTeam === "object" && params.row.homeTeam?.name}
          <span
            style={{
              color: `${
                params.row.score.away < params.row.score.home && "#D4AC18"
              }`,
            }}
          >
            {params.row.score.away === null
              ? ""
              : ` - ${params.row.score.home}`}
          </span>
        </div>
      ),
    },
    {
      field: "awayTeam",
      headerName: "קבוצה מתארחת",
      minWidth: 160,
      renderCell: (params: { row: Match }) => (
        <div>
          {typeof params.row.awayTeam === "object" && params.row.awayTeam?.name}
          <span
            style={{
              color: `${
                params.row.score.away > params.row.score.home && "#D4AC18"
              }`,
            }}
          >
            {params.row.score.away === null
              ? ""
              : ` - ${params.row.score.away}`}
          </span>
        </div>
      ),
    },
    {
      field: "season",
      headerName: "עונה",
      minWidth: 60,
    },

    {
      field: "date",
      headerName: "תאריך",
      minWidth: 200,
      renderCell: (params: { row: Match }) => (
        <div>{localHebrewDateFormmater(params.row.createdAt)}</div>
      ),
    },
    {
      field: "createdAt",
      headerName: "נוצר ב- ",
      minWidth: 200,
      renderCell: (params: { row: Match }) => (
        <div>{localHebrewDateFormmater(params.row.createdAt)}</div>
      ),
    },
    {
      field: "actions",
      type: "actions",
      minWidth: 50,
      cellClassName: "actions",
      sortable: false,
      getActions: ({ row }: { row: Match }) => [
        <Tooltip key={`edit-btn-${row._id}`} title="עריכה">
          <div style={{ minWidth: "40px" }}>
            <IconButton
              color="secondary"
              onClick={async () => {
                onOpenMatchDialog(row);
              }}
            >
              <EditIcon />
            </IconButton>
          </div>
        </Tooltip>,
        <Tooltip key={`delete-btn-${row._id}`} title="מחיקה">
          <IconButton
            onClick={async () => {
              await confirm({
                description: `למחוק את המשחק ?`,
              });
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

  async function processRowUpdate(newRow: Match) {
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
      <AppTitle title="משחקים" />
      <DataGrid
        sx={{ marginTop: 10 }}
        rows={matches || []}
        onProcessRowUpdateError={onError}
        processRowUpdate={processRowUpdate}
        columns={columns as GridColDef<Match>[]}
        getRowId={(row: Partial<Match>) => row._id as string}
        initialState={{
          sorting: {
            sortModel: [{ field: "createdAt", sort: "desc" }],
          },
        }}
        slots={{
          toolbar: () => <GridToolbar showQuickFilter />,
        }}
        loading={!matches}
      />

      <AppFab text="הוסף משחק" DialogTrigger={onOpenMatchDialog} />
      <MatchDialog
        open={isMatchDialogOpen}
        onClose={onCloseMatchDialog}
        selectedItem={selectedMatch}
      />
    </div>
  );
}
