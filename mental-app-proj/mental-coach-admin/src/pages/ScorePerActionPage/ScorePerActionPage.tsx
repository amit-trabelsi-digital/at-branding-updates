import { IconButton, Tooltip } from "@mui/material";
import { enqueueSnackbar } from "notistack";
import useSWR from "swr";
import { appFetch } from "../../services/fetch";
import { DataGrid, GridColDef, GridToolbar } from "@mui/x-data-grid";
import { Score } from "../../utils/types";
import useDialog from "../../hooks/useDialog";
import { useState } from "react";
import ScoreDialog from "../../components/dialogs/ScoreDialog";
import EditIcon from "@mui/icons-material/Edit";
import AppTitle from "../../components/general/AppTitle";
import AppFab from "../../components/general/AppFab";
import DeleteIcon from "@mui/icons-material/Delete";
import { useConfirm } from "material-ui-confirm";
import { deleteItem } from "../../utils/tools";

export default function ScorePerActionPage() {
  const baseUrl = "/api/scores";
  const { data: scores, mutate } = useSWR("/api/scores");

  const [selectedScore, setSelectedScore] = useState<Score | null>(null);
  const confirm = useConfirm();

  const {
    open: isScoreDialogOpen,
    closeDialog: onCloseScoreDialog,
    openDialog: onOpenScoreDialog,
  } = useDialog({ initialOpen: false, setItem: setSelectedScore });

  const columns = [
    {
      field: "scoreTrigger",
      headerName: "פעולה",
      minWidth: 200,
    },
    {
      field: "points",
      headerName: "נקודות",
      minWidth: 160,
    },
    {
      field: "branch",
      headerName: "משפחת פעולות",
      minWidth: 60,
    },
    {
      field: "notes",
      headerName: "הערות",
      minWidth: 60,
    },
    {
      field: "actions",
      type: "actions",
      minWidth: 50,
      cellClassName: "actions",
      sortable: false,
      getActions: ({ row }: { row: Score }) => [
        <Tooltip key={`edit-btn-${row._id}`} title="עריכה">
          <div style={{ minWidth: "40px" }}>
            <IconButton
              color="secondary"
              onClick={async () => {
                onOpenScoreDialog(row);
              }}
            >
              <EditIcon />
            </IconButton>
          </div>
        </Tooltip>,
        <Tooltip key={`delete-btn-${row._id}`} title="מחיקה">
          <IconButton
            onClick={async () => {
              await confirm({ description: `למחוק '${row.branch}'?` });
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

  async function processRowUpdate(newRow: Score) {
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
      <AppTitle title={"ניקוד על פעולות"} />

      <DataGrid
        sx={{ marginTop: 10 }}
        rows={scores || []}
        onProcessRowUpdateError={onError}
        processRowUpdate={processRowUpdate}
        columns={columns as GridColDef<Score>[]}
        getRowId={(row: Partial<Score>) => row._id as string}
        initialState={{
          sorting: {
            sortModel: [{ field: "createdAt", sort: "desc" }],
          },
        }}
        slots={{
          toolbar: () => <GridToolbar showQuickFilter />,
        }}
        loading={!scores}
      />

      <AppFab text="הוסף ניקוד" DialogTrigger={onOpenScoreDialog} />
      <ScoreDialog
        open={isScoreDialogOpen}
        onClose={onCloseScoreDialog}
        selectedItem={selectedScore}
      />
    </div>
  );
}
