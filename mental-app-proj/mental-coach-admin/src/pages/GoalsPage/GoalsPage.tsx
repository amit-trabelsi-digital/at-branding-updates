import { IconButton, Tooltip } from "@mui/material";
import { enqueueSnackbar } from "notistack";
import useSWR from "swr";
import { appFetch } from "../../services/fetch";
import { DataGrid, GridColDef, GridToolbar } from "@mui/x-data-grid";
import { Goal } from "../../utils/types";
import useDialog from "../../hooks/useDialog";
import { useState } from "react";
import EditIcon from "@mui/icons-material/Edit";
import DeleteIcon from "@mui/icons-material/Delete";

import { LabelsList } from "../../components/general/GeneralRenderComp";
import GoalDialog from "../../components/dialogs/GoalDialog";
import CheckBoxOutlineBlankIcon from "@mui/icons-material/CheckBoxOutlineBlank";
import CheckBoxIcon from "@mui/icons-material/CheckBox";
import AppTitle from "../../components/general/AppTitle";
import AppFab from "../../components/general/AppFab";
import { useConfirm } from "material-ui-confirm";
import { deleteItem } from "../../utils/tools";
export default function GoalsPage() {
  const baseUrl = "/api/goals";
  const { data: goals, mutate } = useSWR(baseUrl);

  const [selectedGoal, setSelectedGoal] = useState<Goal | null>(null);
  const confirm = useConfirm();

  console.log(goals);
  const {
    open: isGoalDialogOpen,
    closeDialog: onCloseGoalDialog,
    openDialog: onOpenGoalDialog,
  } = useDialog({ initialOpen: false, setItem: setSelectedGoal });

  const columns = [
    {
      field: "goalName",
      headerName: "מטרה",
      minWidth: 250,
    },
    {
      field: "positions",
      headerName: "עמדות",
      minWidth: 250,
      renderCell: (params: { row: Goal }) => LabelsList(params.row.positions),
    },
    {
      field: "measurable",
      headerName: "מדיד",
      minWidth: 200,
      renderCell: (params: { row: Goal }) => (
        <span>
          {params.row.measurable ? (
            <CheckBoxIcon />
          ) : (
            <CheckBoxOutlineBlankIcon />
          )}
        </span>
      ),
    },
    {
      field: "trainingCompatible",
      headerName: "תואם אימון",
      minWidth: 200,
      renderCell: (params: { row: Goal }) => (
        <span>
          {params.row.trainingCompatible ? (
            <CheckBoxIcon />
          ) : (
            <CheckBoxOutlineBlankIcon />
          )}
        </span>
      ),
    },

    {
      field: "actions",
      type: "actions",
      minWidth: 50,
      cellClassName: "actions",
      sortable: false,
      getActions: ({ row }: { row: Goal }) => [
        <Tooltip key={`edit-btn-${row._id}`} title="עריכה">
          <div style={{ minWidth: "40px" }}>
            <IconButton
              color="primary"
              onClick={async () => {
                onOpenGoalDialog(row);
              }}
            >
              <EditIcon />
            </IconButton>
          </div>
        </Tooltip>,
        <Tooltip key={`delete-btn-${row._id}`} title="מחיקה">
          <IconButton
            onClick={async () => {
              await confirm({ description: `למחוק '${row.goalName}'?` });
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

  async function processRowUpdate(newRow: Goal) {
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
      <AppTitle title={"מטרות"} />
      <DataGrid
        sx={{ marginTop: 10 }}
        rows={goals || []}
        onProcessRowUpdateError={onError}
        processRowUpdate={processRowUpdate}
        columns={columns as GridColDef<Goal>[]}
        getRowId={(row: Partial<Goal>) => row._id as string}
        initialState={{
          sorting: {
            sortModel: [{ field: "createdAt", sort: "desc" }],
          },
        }}
        slots={{
          toolbar: () => <GridToolbar showQuickFilter />,
        }}
        loading={!goals}
      />
      <AppFab text=" הוסף מטרה" DialogTrigger={onOpenGoalDialog} />
      <GoalDialog
        open={isGoalDialogOpen}
        onClose={onCloseGoalDialog}
        selectedItem={selectedGoal}
      />
    </div>
  );
}
