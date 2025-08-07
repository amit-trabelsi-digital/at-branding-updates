import { Button, IconButton, Tooltip } from "@mui/material";
import { enqueueSnackbar } from "notistack";
import useSWR from "swr";
import { appFetch } from "../../services/fetch";
import { DataGrid, GridColDef, GridToolbar } from "@mui/x-data-grid";
import { Case, CaseAndResponse } from "../../utils/types";
import useDialog from "../../hooks/useDialog";
import { useState } from "react";
import CaseAndReactionsDialog from "../../components/dialogs/CaseAndReactionsDialog";
import EditIcon from "@mui/icons-material/Edit";
import DeleteIcon from "@mui/icons-material/Delete";
import { deleteItem, renderResponseState } from "../../utils/tools";
import { LabelsList } from "../../components/general/GeneralRenderComp";
import AppTitle from "../../components/general/AppTitle";
import AppFab from "../../components/general/AppFab";
import { useConfirm } from "material-ui-confirm";

export default function CaseAndReactionsPage() {
  const baseUrl = "/api/cases";
  const { data: cases, mutate } = useSWR(baseUrl);

  const [selectedCase, setSelectedCase] = useState<CaseAndResponse | null>(
    null
  );

  const confirm = useConfirm();

  console.log(cases);
  const {
    open: isCaseAndReactionsDialogOpen,
    closeDialog: onCloseCaseAndReactionsDialog,
    openDialog: onOpenCaseAndReactionsDialog,
  } = useDialog({ initialOpen: false, setItem: setSelectedCase });

  const columns = [
    {
      field: "responseState",
      headerName: "מצב מקרה",
      minWidth: 200,
      renderCell: (params: { row: Case }) => {
        return <div> {renderResponseState(params.row.responseState)}</div>;
      },
    },
    {
      field: "case",
      headerName: "מקרה",
      minWidth: 250,
    },
    {
      field: "positions",
      headerName: "עמדות",
      minWidth: 250,
      renderCell: (params: { row: Case }) => LabelsList(params.row.positions),
    },
    {
      field: "response",
      headerName: "תגובה",
      minWidth: 200,
    },
    {
      field: "link",
      headerName: "קישור",
      minWidth: 200,
      renderCell: (params: { row: Case }) => (
        <Button variant="outlined" sx={{ paddingX: 4 }} href={params.row.link}>
          {" "}
          קישור
        </Button>
      ),
    },

    {
      field: "tags",
      headerName: "תגיות",
      minWidth: 150,
      renderCell: (params: { row: Case }) => LabelsList(params.row.tags),
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
      getActions: ({ row }: { row: CaseAndResponse }) => [
        <Tooltip key={`edit-btn-${row._id}`} title="עריכה">
          <div style={{ minWidth: "40px" }}>
            <IconButton
              color="primary"
              onClick={async () => {
                onOpenCaseAndReactionsDialog(row);
              }}
            >
              <EditIcon />
            </IconButton>
          </div>
        </Tooltip>,
        <Tooltip key={`delete-btn-${row._id}`} title="מחיקה">
          <IconButton
            onClick={async () => {
              await confirm({ description: `למחוק '${row.case}'?` });
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

  async function processRowUpdate(newRow: CaseAndResponse) {
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
    <>
      <AppTitle title={"מקרים ותגובות"} />
      <DataGrid
        sx={{ marginTop: 10 }}
        rows={cases || []}
        onProcessRowUpdateError={onError}
        processRowUpdate={processRowUpdate}
        columns={columns as GridColDef<CaseAndResponse>[]}
        getRowId={(row: Partial<CaseAndResponse>) => row._id as string}
        initialState={{
          sorting: {
            sortModel: [{ field: "createdAt", sort: "desc" }],
          },
        }}
        slots={{
          toolbar: () => <GridToolbar showQuickFilter />,
        }}
        loading={!cases}
      />

      <AppFab text="הוסף מקרה" DialogTrigger={onOpenCaseAndReactionsDialog} />
      <CaseAndReactionsDialog
        open={isCaseAndReactionsDialogOpen}
        onClose={onCloseCaseAndReactionsDialog}
        selectedItem={selectedCase}
      />
    </>
  );
}
