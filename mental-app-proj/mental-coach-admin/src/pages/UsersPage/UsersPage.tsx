import { 
  IconButton, 
  Tooltip, 
  Stack, 
  Button, 
  Box, 
  MenuItem,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  FormControl,
  InputLabel,
  Select
} from "@mui/material";
import { enqueueSnackbar } from "notistack";
import useSWR from "swr";
import { appFetch } from "../../services/fetch";
import { DataGrid, GridColDef, GridToolbar, GridRowSelectionModel } from "@mui/x-data-grid";
import { User } from "../../utils/types";
import useDialog from "../../hooks/useDialog";
import UserDialog from "../../components/dialogs/UserDialog";
import { useState } from "react";
import PersonAddIcon from "@mui/icons-material/PersonAdd";
import { localHebrewDateFormmater } from "../../utils/tools";
import EditIcon from "@mui/icons-material/Edit";
import AppTitle from "../../components/general/AppTitle";
import AppFab from "../../components/general/AppFab";
import AppColorBall from "../../components/general/AppColorBall";
import AdminPanelSettingsIcon from "@mui/icons-material/AdminPanelSettings";
import EmailIcon from "@mui/icons-material/Email";
import SmsIcon from "@mui/icons-material/Sms";
import GoogleIcon from "@mui/icons-material/Google";
import DeleteIcon from "@mui/icons-material/Delete";
import SubscriptionsIcon from "@mui/icons-material/Subscriptions";
import ConfirmDialog from "../../components/dialogs/ConfirmDialog";
export default function UsersPage() {
  const baseUrl = "/api/users";
  const { data: users, mutate } = useSWR("/api/users");

  const [selectedUser, setSelectedUser] = useState<User | null>(null);
  const [selectedRows, setSelectedRows] = useState<GridRowSelectionModel>([]);
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
  const [subscriptionDialogOpen, setSubscriptionDialogOpen] = useState(false);
  const [newSubscriptionType, setNewSubscriptionType] = useState<string>("");

  const {
    open: isUserDialogOpen,
    closeDialog: onCloseUserDialog,
    openDialog: onOpenUserDialog,
  } = useDialog({ initialOpen: false, setItem: setSelectedUser });

  console.log(users);
  const columns = [
    {
      field: "nickName",
      headerName: "כינוי חשבון",
      minWidth: 130,
    },
    {
      field: "subscriptionType",
      headerName: "סוג מנוי",
      minWidth: 60,
    },
    {
      field: "profile",
      headerName: "שם משתמש",
      minWidth: 160,
      renderCell: (params: { row: User }) => (
        <div style={{ display: "flex", alignItems: "center" }}>
          {params.row.role === 0 && (
            <AdminPanelSettingsIcon sx={{ color: "darkgoldenrod" }} />
          )}
          {`${params.row.firstName} ${params.row.lastName}`}
        </div>
      ),
    },
    {
      field: "age",
      headerName: "גיל",
      width: 50,

      renderCell: (params: { row: User }) => <div>{params.row.age}</div>,
    },
    {
      field: "email",
      headerName: "מייל",
      minWidth: 210,
    },
    {
      field: "totalWins",
      headerName: "נצחונות",
      width: 70,
    },
    {
      field: "totalScore",
      headerName: "ציון כולל",
      width: 70,
    },
    {
      field: "position",
      headerName: "עמדה",
      width: 70,
      renderCell: (params: { row: User }) => <div>{params.row.position}</div>,
    },
    {
      field: "phone",
      headerName: "טלפון",
      minWidth: 120,
      renderCell: (params: { row: User }) => (
        <div>{params.row.phone || "חסר"}</div>
      ),
    },
    {
      field: "authMethods",
      headerName: "שיטות התחברות",
      minWidth: 150,
      renderCell: (params: { row: User }) => {
        const methods = params.row.allowedAuthMethods || {};
        return (
          <Stack direction="row" spacing={0.5}>
            {methods.email && (
              <Tooltip title="אימייל">
                <EmailIcon fontSize="small" color="action" />
              </Tooltip>
            )}
            {methods.sms && (
              <Tooltip title="SMS">
                <SmsIcon fontSize="small" color="action" />
              </Tooltip>
            )}
            {methods.google && (
              <Tooltip title="Google">
                <GoogleIcon fontSize="small" color="action" />
              </Tooltip>
            )}
          </Stack>
        );
      },
    },
    {
      field: "createdAt",
      headerName: "נוצר ב- ",
      minWidth: 200,
      renderCell: (params: { row: User }) => (
        <div>{localHebrewDateFormmater(params.row.createdAt)}</div>
      ),
    },
    {
      field: "hex1",
      headerName: "צבע ראשי",
      renderCell: (params: { row: User }) => {
        return (
          <div
            style={{
              paddingTop: 8,
            }}
          >
            <AppColorBall hexColor={params.row?.selectedTeamColor?.hex1} />
          </div>
        );
      },
      width: 70,
    },
    {
      field: "hex2",
      headerName: "צבע משני",
      renderCell: (params: { row: User }) => {
        return (
          <div
            style={{
              paddingTop: 8,
            }}
          >
            <AppColorBall
              hexColor={params.row?.selectedTeamColor?.hex2}
              size="medium"
            />
          </div>
        );
      },
      width: 70,
    },
    {
      field: "hex3",
      headerName: "צבע שלישי",
      renderCell: (params: { row: User }) => {
        return (
          <div
            style={{
              paddingTop: 8,
            }}
          >
            <AppColorBall
              hexColor={params.row?.selectedTeamColor?.hex3}
              size="small"
            />
          </div>
        );
      },
      width: 80,
    },
    {
      field: "actions",
      type: "actions",
      minWidth: 50 * 7,
      cellClassName: "actions",
      sortable: false,
      getActions: ({ row }: { row: User }) => [
        <Tooltip key={`edit-btn-${row._id}`} title="עריכה">
          <div style={{ minWidth: "40px" }}>
            <IconButton
              color="secondary"
              onClick={async () => {
                onOpenUserDialog(row);
              }}
            >
              <EditIcon />
            </IconButton>
          </div>
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

  async function processRowUpdate(newRow: User) {
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

  const handleDeleteSelected = async () => {
    try {
      // Delete all selected users
      const deletePromises = selectedRows.map(id => 
        appFetch(`${baseUrl}/${id}`, { method: "DELETE" })
      );
      
      await Promise.all(deletePromises);
      
      mutate();
      setSelectedRows([]);
      setDeleteDialogOpen(false);
      enqueueSnackbar(`${selectedRows.length} משתמשים נמחקו בהצלחה`, { variant: "success" });
    } catch (err) {
      enqueueSnackbar("שגיאה במחיקת המשתמשים", { variant: "error" });
    }
  };

  const handleUpdateSubscription = async () => {
    try {
      // Update subscription for all selected users
      const updatePromises = selectedRows.map(id => 
        appFetch(`${baseUrl}/${id}`, {
          method: "PUT",
          body: JSON.stringify({ subscriptionType: newSubscriptionType }),
        })
      );
      
      await Promise.all(updatePromises);
      
      mutate();
      setSelectedRows([]);
      setSubscriptionDialogOpen(false);
      setNewSubscriptionType("");
      enqueueSnackbar(`סוג המנוי עודכן ל-${selectedRows.length} משתמשים`, { variant: "success" });
    } catch (err) {
      enqueueSnackbar("שגיאה בעדכון סוג המנוי", { variant: "error" });
    }
  };

  return (
    <div>
      <AppTitle title="משתמשים" />
      
      {selectedRows.length > 0 && (
        <Box sx={{ mb: 2, display: 'flex', gap: 2 }}>
          <Button
            variant="contained"
            color="error"
            startIcon={<DeleteIcon />}
            onClick={() => setDeleteDialogOpen(true)}
          >
            מחק {selectedRows.length} משתמשים
          </Button>
          <Button
            variant="contained"
            color="primary"
            startIcon={<SubscriptionsIcon />}
            onClick={() => setSubscriptionDialogOpen(true)}
          >
            שנה סוג מנוי ל-{selectedRows.length} משתמשים
          </Button>
        </Box>
      )}

      <DataGrid
        sx={{ 
          marginTop: selectedRows.length > 0 ? 2 : 10,
          '& .MuiDataGrid-row': {
            cursor: 'pointer',
            '&:hover': {
              backgroundColor: 'action.hover',
            },
          },
        }}
        rows={users || []}
        onProcessRowUpdateError={onError}
        processRowUpdate={processRowUpdate}
        columns={columns as GridColDef<User>[]}
        getRowId={(row: Partial<User>) => row._id as string}
        initialState={{
          sorting: {
            sortModel: [{ field: "createdAt", sort: "desc" }],
          },
        }}
        slots={{
          toolbar: () => <GridToolbar showQuickFilter />,
        }}
        loading={!users}
        checkboxSelection
        rowSelectionModel={selectedRows}
        onRowSelectionModelChange={(newSelection) => {
          setSelectedRows(newSelection);
        }}
        onRowClick={(params, event) => {
          // Prevent opening dialog when clicking checkbox
          const target = event.target as HTMLElement;
          if (!target.closest('.MuiCheckbox-root')) {
            onOpenUserDialog(params.row);
          }
        }}
      />

      <AppFab
        icon={<PersonAddIcon sx={{ mr: 1 }} />}
        text="הוסף משתמש"
        DialogTrigger={onOpenUserDialog}
      />

      <UserDialog
        open={isUserDialogOpen}
        onClose={onCloseUserDialog}
        selectedItem={selectedUser}
      />

      <ConfirmDialog
        open={deleteDialogOpen}
        onClose={() => setDeleteDialogOpen(false)}
        onConfirm={handleDeleteSelected}
        title="מחיקת משתמשים"
        content={`האם אתה בטוח שברצונך למחוק ${selectedRows.length} משתמשים? פעולה זו אינה ניתנת לביטול.`}
      />

      <Dialog
        open={subscriptionDialogOpen}
        onClose={() => {
          setSubscriptionDialogOpen(false);
          setNewSubscriptionType("");
        }}
      >
        <DialogTitle>שינוי סוג מנוי</DialogTitle>
        <DialogContent sx={{ minWidth: 300, pt: 2 }}>
          <FormControl fullWidth>
            <InputLabel>סוג מנוי חדש</InputLabel>
            <Select
              value={newSubscriptionType}
              onChange={(e) => setNewSubscriptionType(e.target.value)}
              label="סוג מנוי חדש"
            >
              <MenuItem value="basic">בסיסי</MenuItem>
              <MenuItem value="advanced">מתקדם</MenuItem>
              <MenuItem value="premium">פרימיום</MenuItem>
            </Select>
          </FormControl>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => {
            setSubscriptionDialogOpen(false);
            setNewSubscriptionType("");
          }}>
            ביטול
          </Button>
          <Button 
            onClick={handleUpdateSubscription} 
            variant="contained"
            disabled={!newSubscriptionType}
          >
            עדכן מנוי ל-{selectedRows.length} משתמשים
          </Button>
        </DialogActions>
      </Dialog>
    </div>
  );
}
