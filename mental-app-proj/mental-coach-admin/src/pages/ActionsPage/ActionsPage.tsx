import { IconButton, Tooltip } from "@mui/material";
import { enqueueSnackbar } from "notistack";
import useSWR from "swr";
import { appFetch } from "../../services/fetch";
import { DataGrid, GridColDef, GridToolbar } from "@mui/x-data-grid";
import { Action } from "../../utils/types";
import useDialog from "../../hooks/useDialog";
import { useState } from "react";
import EditIcon from "@mui/icons-material/Edit";
import { LabelsList } from "../../components/general/GeneralRenderComp";
import CheckBoxOutlineBlankIcon from "@mui/icons-material/CheckBoxOutlineBlank";
import CheckBoxIcon from "@mui/icons-material/CheckBox";
import ActionDialog from "../../components/dialogs/ActionDialog";
import AppTitle from "../../components/general/AppTitle";
import AppFab from "../../components/general/AppFab";
import DeleteIcon from "@mui/icons-material/Delete";
import { useConfirm } from "material-ui-confirm";
import { deleteItem } from "../../utils/tools";
export default function ActionsPage() {
  const baseUrl = "/api/actions";
  const { data: actions, mutate } = useSWR(baseUrl);

  const [selectedAction, setSelectedAction] = useState<Action | null>(null);
  const confirm = useConfirm();

  const {
    open: isActionDialogOpen,
    closeDialog: onCloseActionDialog,
    openDialog: onOpenActionDialog,
  } = useDialog({ initialOpen: false, setItem: setSelectedAction });

  const columns = [
    {
      field: "actionName",
      headerName: "מטרה",
      minWidth: 250,
    },
    {
      field: "positions",
      headerName: "עמדות",
      minWidth: 300,
      renderCell: (params: { row: Action }) =>
        LabelsList(params.row.positions, "300px"),
    },
    {
      field: "measurable",
      headerName: "מדיד",
      minWidth: 200,
      renderCell: (params: { row: Action }) => (
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
      renderCell: (params: { row: Action }) => (
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
      getActions: ({ row }: { row: Action }) => [
        <Tooltip key={`edit-btn-${row._id}`} title="עריכה">
          <div style={{ minWidth: "40px" }}>
            <IconButton
              color="primary"
              onClick={async () => {
                onOpenActionDialog(row);
              }}
            >
              <EditIcon />
            </IconButton>
          </div>
        </Tooltip>,
        <Tooltip key={`delete-btn-${row._id}`} title="מחיקה">
          <IconButton
            onClick={async () => {
              await confirm({ description: `למחוק '${row.actionName}'?` });
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

  const onSuccess = (message = "שינויים נשמרו") => {
    enqueueSnackbar(message);
    mutate();
  };

  type Error = {
    message: string;
  };
  const onError = (err: Error) => {
    enqueueSnackbar(err.message || "שגיאה", { variant: "error" });
  };

  async function processRowUpdate(newRow: Action) {
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
      <AppTitle title="פעולות" />
      <DataGrid
        sx={{ marginTop: 10 }}
        rows={actions || []}
        onProcessRowUpdateError={onError}
        processRowUpdate={processRowUpdate}
        columns={columns as GridColDef<Action>[]}
        getRowId={(row: Partial<Action>) => row._id as string}
        initialState={{
          sorting: {
            sortModel: [{ field: "createdAt", sort: "desc" }],
          },
        }}
        slots={{
          toolbar: () => <GridToolbar showQuickFilter />,
        }}
        loading={!actions}
      />

      <AppFab text="הוסף פעולה" DialogTrigger={onOpenActionDialog} />
      <ActionDialog
        open={isActionDialogOpen}
        onClose={onCloseActionDialog}
        selectedItem={selectedAction}
      />
    </div>
  );
}
