import { yupResolver } from "@hookform/resolvers/yup";
import CloseIcon from "@mui/icons-material/Close";
import { LoadingButton } from "@mui/lab";
import {
  AppBar,
  Button,
  IconButton,
  MenuItem,
  Stack,
  Toolbar,
  Typography,
} from "@mui/material";
import { useEffect, useState } from "react";
import { useForm } from "react-hook-form";
import * as yup from "yup";
import {
  yupStringSchema,
  yupStringSchema_optional,
} from "../../utils/validators";

import EditIcon from "@mui/icons-material/Edit";
import { enqueueSnackbar } from "notistack";
import useSWR, { mutate } from "swr";
import { appFetch } from "../../services/fetch";
import { BaseDialogProps, League, Team } from "../../utils/types";
import AppSelectWithController from "../general/AppSelectWithController";
import { COUNTRIES_LIST } from "../../data/lists";
import AppAutoCompleteMultiSelectWithController from "../general/AppAutoCompleteMultiSelectWithController";
import AppSubtitle from "../general/AppSubtitle";
import AppFormTextField from "../general/AppFormTextField";
import AppDialog from "../general/AppDialog";

type Props = BaseDialogProps & { selectedItem: League | null };

const fixedTeamArrayFunction = (data: unknown): { value: string | undefined, label: string | undefined }[] => {
  if (!Array.isArray(data)) {
    return [];
  }
  const fixedDataArray = data.map((team: Partial<Team>) => {
    return { value: team?._id, label: team?.name };
  });
  return fixedDataArray;
};

function LeagueDialog({ open, onClose, selectedItem }: Props) {
  const { data } = useSWR<Team[]>("/api/teams");

  const [loading, setLoading] = useState(false);
  const [isEditMode, setIsEditMode] = useState(false);
  const isCreationMode = !selectedItem;
  const isViewMode = !isCreationMode && !isEditMode;

  const objectSchema = {
    name: yupStringSchema,
    country: yupStringSchema.default(COUNTRIES_LIST[0].value),
    season: yupStringSchema_optional,
    teams: yup.array(),
  };
  const schema = yup.object().shape(objectSchema);

  const {
    register,
    handleSubmit,
    formState: { errors },
    setValue,
    reset,
    control,
  } = useForm({
    resolver: yupResolver(schema),
    defaultValues: schema.getDefault(),
  });

  useEffect(() => {
    if (selectedItem) {
      console.log(selectedItem);
      for (const key in objectSchema) {
        const _key = key as keyof typeof objectSchema;
        const value = selectedItem[_key] ?? null;
        console.log(value);
        if (_key === "teams" && typeof value === "object") {
          setValue(_key, fixedTeamArrayFunction(value));
        } else {
          setValue(_key, value as string);
        }
      }
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [selectedItem]);

  const onSubmit = handleSubmit(async (data) => {
    setLoading(true);
    try {
      const res = await appFetch(
        isCreationMode ? "/api/leagues" : `/api/leagues/${selectedItem!._id}`,
        {
          method: isCreationMode ? "POST" : "PUT",
          body: JSON.stringify(data),
        }
      );
      if (!res.ok) throw new Error();
      enqueueSnackbar(isEditMode ? "השינויים נשמרו" : `ליגה חדש נוצר`);
      onCloseHandler();
      mutate("/api/leagues");
    } catch (error) {
      console.error(error);
      enqueueSnackbar(`שגיאה`, {
        variant: "error",
      });
    } finally {
      setLoading(false);
    }
  });

  const onCloseHandler = () => {
    onClose();
    reset();
    setIsEditMode(false);
  };

  return (
    <AppDialog open={open} onClose={onCloseHandler}>
      <AppBar sx={{ position: "relative" }}>
        <Toolbar>
          <IconButton
            edge="start"
            color="inherit"
            onClick={onCloseHandler}
            aria-label="close"
          >
            <CloseIcon />
          </IconButton>
          {(isEditMode || isCreationMode) && (
            <Typography sx={{ ml: 2, flex: 1 }} variant="h6" component="div">
              {isEditMode ? "ערוך" : "צור"} ליגה{" "}
            </Typography>
          )}
        </Toolbar>
      </AppBar>
      <form onSubmit={onSubmit}>
        <Stack
          maxWidth={500}
          mx={"auto"}
          py={5}
          spacing={1.5}
          sx={{
            ".MuiOutlinedInput-notchedOutline": isViewMode
              ? {
                  border: "#f0f0f0 solid 1px !important",
                  "&:hover": { border: "#f0f0f0 solid 1px !important" },
                }
              : {},
            ".MuiFormLabel-root": isViewMode
              ? { color: "#666 !important" }
              : {},
          }}
        >
          {isViewMode && (
            <Button
              variant="outlined"
              sx={{ width: "fit-content", alignSelf: "flex-end" }}
              startIcon={<EditIcon />}
              onClick={() => setIsEditMode(true)}
              disabled={isEditMode}
            >
              עריכה
            </Button>
          )}
          <AppSubtitle>פרטי ליגה</AppSubtitle>

          <AppFormTextField
            register={register}
            errors={errors}
            isViewMode={isViewMode}
            fieldKey="name"
            label={"שם הליגה"}
          />
          <AppSelectWithController
            isViewMode={isViewMode}
            errors={errors}
            required
            label="מדינה"
            fieldKey="country"
            control={control}
          >
            {COUNTRIES_LIST.map((i) => (
              <MenuItem value={i.value} key={i.value}>
                {`${i.label}`}
              </MenuItem>
            ))}
          </AppSelectWithController>

          <AppAutoCompleteMultiSelectWithController
            isViewMode={isViewMode}
            label="קבוצות"
            control={control}
            fieldKey="teams"
            options={
              fixedTeamArrayFunction(data) || [
                { label: "אין מידע", value: "0" },
              ]
            }
            errors={errors}
          />
          {!isViewMode && (
            <LoadingButton loading={loading} type="submit" variant="contained">
              {isEditMode ? "שמור" : "צור"}
            </LoadingButton>
          )}
        </Stack>
      </form>
      <div>
        {errors["teams"]?.message}
        {errors["country"]?.message}
      </div>
    </AppDialog>
  );
}

export default LeagueDialog;
