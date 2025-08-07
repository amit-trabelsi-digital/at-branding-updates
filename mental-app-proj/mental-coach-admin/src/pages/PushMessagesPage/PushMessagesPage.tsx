import { Button, IconButton, Tooltip } from "@mui/material";
import { enqueueSnackbar } from "notistack";
import useSWR from "swr";
import { appFetch } from "../../services/fetch";
import { DataGrid, GridColDef, GridToolbar } from "@mui/x-data-grid";
import { PushMessages } from "../../utils/types";
import useDialog from "../../hooks/useDialog";
import { useState } from "react";
import EditIcon from "@mui/icons-material/Edit";
import { deleteItem, renderResponseState } from "../../utils/tools";
import PushMessagesDialog from "../../components/dialogs/PushMessagesDialog";
import AppTitle from "../../components/general/AppTitle";
import AppFab from "../../components/general/AppFab";
import DeleteIcon from "@mui/icons-material/Delete";
import { useConfirm } from "material-ui-confirm";

export default function PushMessagesPage() {
  const baseUrl = "/api/pushMessages";
  const { data: pushMessages, mutate } = useSWR(baseUrl);

  const confirm = useConfirm();

  const [selectedPushMessages, setSelectedPushMessages] =
    useState<PushMessages | null>(null);

  console.log(pushMessages);
  const {
    open: isPushMessagesDialogOpen,
    closeDialog: onClosePushMessagesDialog,
    openDialog: onOpenPushMessagesDialog,
  } = useDialog({ initialOpen: false, setItem: setSelectedPushMessages });

  const columns = [
    {
      field: "title",
      headerName: "שם המסר",
      minWidth: 200,
      renderCell: (params: { row: PushMessages }) => {
        return <div> {renderResponseState(params.row.title)}</div>;
      },
    },
    {
      field: "message",
      headerName: "תכולת המסר",
      minWidth: 250,
    },
    {
      field: "dataLink",
      headerName: "מקרה",
      minWidth: 160,
    },

    {
      field: "appearedIn",
      headerName: "שלב הופעה",
      minWidth: 160,
    },

    {
      field: "readMoreLink",
      headerName: "קישור",
      minWidth: 200,
      renderCell: (params: { row: PushMessages }) => (
        <Button
          variant="outlined"
          sx={{ paddingX: 4 }}
          href={params.row.readMoreLink}
        >
          {" "}
          קישור
        </Button>
      ),
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
      getActions: ({ row }: { row: PushMessages }) => [
        <Tooltip key={`edit-btn-${row._id}`} title="עריכה">
          <div style={{ minWidth: "40px" }}>
            <IconButton
              color="primary"
              onClick={async () => {
                onOpenPushMessagesDialog(row);
              }}
            >
              <EditIcon />
            </IconButton>
          </div>
        </Tooltip>,
        <Tooltip key={`delete-btn-${row._id}`} title="מחיקה">
          <IconButton
            onClick={async () => {
              await confirm({ description: `למחוק '${row.title}'?` });
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

  async function processRowUpdate(newRow: PushMessages) {
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
      <AppTitle title="הודעות פוש" />

      <DataGrid
        sx={{ marginTop: 10 }}
        rows={pushMessages || []}
        onProcessRowUpdateError={onError}
        processRowUpdate={processRowUpdate}
        columns={columns as GridColDef<PushMessages>[]}
        getRowId={(row: Partial<PushMessages>) => row._id as string}
        initialState={{
          sorting: {
            sortModel: [{ field: "createdAt", sort: "desc" }],
          },
        }}
        slots={{
          toolbar: () => <GridToolbar showQuickFilter />,
        }}
        loading={!pushMessages}
      />

      <AppFab text="הוסף הודעת פוש" DialogTrigger={onOpenPushMessagesDialog} />

      <PushMessagesDialog
        open={isPushMessagesDialogOpen}
        onClose={onClosePushMessagesDialog}
        selectedItem={selectedPushMessages}
      />
    </div>
  );
}
