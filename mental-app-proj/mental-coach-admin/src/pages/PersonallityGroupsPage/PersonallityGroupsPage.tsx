import { IconButton, Tooltip } from "@mui/material";
import { enqueueSnackbar } from "notistack";
import useSWR from "swr";
import { appFetch } from "../../services/fetch";
import { DataGrid, GridColDef, GridToolbar } from "@mui/x-data-grid";
import { Case, PersonallityGroup } from "../../utils/types";
import useDialog from "../../hooks/useDialog";
import { useState } from "react";
import PersonallityGroupDialog from "../../components/dialogs/PersonallityGroupDialog";
import EditIcon from "@mui/icons-material/Edit";
import { LabelsList } from "../../components/general/GeneralRenderComp";
import AppTitle from "../../components/general/AppTitle";
import AppFab from "../../components/general/AppFab";
import DeleteIcon from "@mui/icons-material/Delete";
import { deleteItem } from "../../utils/tools";
import { useConfirm } from "material-ui-confirm";

export default function PersonallityGroupPage() {
  const baseUrl = "/api/personallity-groups";

  const { data, mutate } = useSWR(baseUrl);

  const [selectedCase, setSelectedCase] = useState<PersonallityGroup | null>(
    null
  );
  console.log(data);

  const confirm = useConfirm();

  const {
    open: isPersonallityGroupDialogOpen,
    closeDialog: onClosePersonallityGroupDialog,
    openDialog: onOpenPersonallityGroupDialog,
  } = useDialog({ initialOpen: false, setItem: setSelectedCase });

  const columns = [
    {
      field: "title",
      headerName: "כותרת",
      minWidth: 160,
    },

    {
      field: "tags",
      headerName: "תגיות",
      minWidth: 500,
      renderCell: (params: { row: Case }) =>
        LabelsList(params.row.tags, "500px"),
    },

    {
      field: "actions",
      type: "actions",
      minWidth: 50,
      cellClassName: "actions",
      sortable: false,
      getActions: ({ row }: { row: PersonallityGroup }) => [
        <Tooltip key={`edit-btn-${row._id}`} title="עריכה">
          <div style={{ minWidth: "40px" }}>
            <IconButton
              color="primary"
              onClick={async () => {
                onOpenPersonallityGroupDialog(row);
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

  async function processRowUpdate(newRow: PersonallityGroup) {
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
      <AppTitle title={"משפחות אופי"} />
      <DataGrid
        sx={{ marginTop: 10 }}
        rows={data || []}
        onProcessRowUpdateError={onError}
        processRowUpdate={processRowUpdate}
        columns={columns as GridColDef<PersonallityGroup>[]}
        getRowId={(row: Partial<PersonallityGroup>) => row._id as string}
        initialState={{
          sorting: {
            sortModel: [{ field: "createdAt", sort: "desc" }],
          },
        }}
        slots={{
          toolbar: () => <GridToolbar showQuickFilter />,
        }}
        loading={!data}
      />

      <AppFab
        text="הוסף משפחת אופי"
        DialogTrigger={onOpenPersonallityGroupDialog}
      />
      <PersonallityGroupDialog
        open={isPersonallityGroupDialogOpen}
        onClose={onClosePersonallityGroupDialog}
        selectedItem={selectedCase}
      />
    </>
  );
}
