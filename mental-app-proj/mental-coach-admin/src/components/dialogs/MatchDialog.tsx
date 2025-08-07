/* eslint-disable @typescript-eslint/no-explicit-any */
import { yupResolver } from "@hookform/resolvers/yup";
import CloseIcon from "@mui/icons-material/Close";
import { LoadingButton } from "@mui/lab";
import { LocalizationProvider } from "@mui/x-date-pickers/LocalizationProvider";
import { MobileDatePicker } from "@mui/x-date-pickers/MobileDatePicker";
import { AdapterDayjs } from "@mui/x-date-pickers/AdapterDayjs";
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
import { Controller, useForm } from "react-hook-form";
import * as yup from "yup";
import { yupStringSchema } from "../../utils/validators";

import EditIcon from "@mui/icons-material/Edit";
import { enqueueSnackbar } from "notistack";
import useSWR, { mutate } from "swr";
import { appFetch } from "../../services/fetch";
import { BaseDialogProps, Match, Team } from "../../utils/types";
import AppSelectWithController from "../general/AppSelectWithController";
import { fixedTeamArrayFunction } from "../../utils/tools";
import dayjs from "dayjs";
import AppSubtitle from "../general/AppSubtitle";
import AppFormTextField from "../general/AppFormTextField";
import AppDialog from "../general/AppDialog";

type Props = BaseDialogProps & { selectedItem: Match | null };

function MatchDialog({ open, onClose, selectedItem }: Props) {
  const { data: teams } = useSWR<Team[]>("/api/teams");

  const [loading, setLoading] = useState(false);
  const [isEditMode, setIsEditMode] = useState(false);
  const isCreationMode = !selectedItem;
  const isViewMode = !isCreationMode && !isEditMode;
  console.log(selectedItem);

  const objectSchema = {
    date: yup.date().nullable().required("תאריך חובה"),
    homeTeam: yupStringSchema,
    awayTeam: yupStringSchema,
    season: yup.string().optional().default(""), // Optional string field
    score: yup.object({
      home: yup
        .number()
        .nullable()
        .default(null)
        .min(0, "תוצאה לא יכולה להיות שלילית"),
      away: yup
        .number()
        .nullable()
        .default(null)
        .min(0, "תוצאה לא יכולה להיות שלילית"),
    }),
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
    defaultValues: {
      date: undefined,
      homeTeam: "",
      awayTeam: "",
      season: "",
      score: { home: null, away: null },
    },
  });

  useEffect(() => {
    if (selectedItem) {
      for (const key in objectSchema) {
        const _key = key as keyof typeof objectSchema;
        const value = selectedItem[_key] ?? null;

        if (_key === "date") {
          setValue("date", dayjs(selectedItem.date) as any);
        } else if (_key === "score") {
          if (
            typeof value === "object" &&
            value !== null &&
            "home" in value &&
            "away" in value
          ) {
            setValue("score.away", value.away as number);
            setValue("score.home", value.home as number);
          }
        } else {
          if (typeof value === "string") {
            setValue(_key, value);
          }
          if (value && typeof value === "object" && "_id" in value) {
            setValue(_key, value._id!);
          }
        }
      }
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [selectedItem]);

  const onSubmit = handleSubmit(async (data) => {
    console.log(data);
    setLoading(true);
    try {
      const res = await appFetch(
        isCreationMode ? "/api/matches" : `/api/matches/${selectedItem!._id}`,
        {
          method: isCreationMode ? "POST" : "PUT",
          body: JSON.stringify(data),
        }
      );
      if (!res.ok) throw new Error();
      enqueueSnackbar(isEditMode ? "השינויים נשמרו" : `משחק חדש נוצר`);
      onCloseHandler();
      mutate("/api/matches");
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

  const teamsOptions = fixedTeamArrayFunction(teams) || [
    { value: "", label: "" },
  ];

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
              {isEditMode ? "ערוך" : "צור"} משחק{" "}
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
          <AppSubtitle>פרטי משחק</AppSubtitle>
          <AppSelectWithController
            errors={errors}
            isViewMode={isViewMode}
            required
            label="קבוצה מארחת"
            fieldKey="homeTeam"
            control={control}
          >
            {teamsOptions?.map((i) => (
              <MenuItem value={i.value} key={i.value}>
                {`${i.label}`}
              </MenuItem>
            ))}
          </AppSelectWithController>
          <AppSelectWithController
            errors={errors}
            isViewMode={isViewMode}
            required
            label="קבוצת חוץ"
            fieldKey="awayTeam"
            control={control}
          >
            {teamsOptions?.map((i) => (
              <MenuItem value={i.value} key={i.value}>
                {`${i.label}`}
              </MenuItem>
            ))}
          </AppSelectWithController>
          <AppFormTextField
            label={"ציון בית"}
            register={register}
            errors={errors}
            type="number"
            fieldKey="score.home"
          />
          <AppFormTextField
            type="number"
            label={"ציון חוץ"}
            register={register}
            errors={errors}
            fieldKey="score.away"
          />
          <LocalizationProvider dateAdapter={AdapterDayjs} adapterLocale="he">
            <Controller
              name="date"
              control={control}
              render={({ field: { ref, ...restField } }) => (
                <MobileDatePicker
                  readOnly={isViewMode}
                  sx={{ width: "100%" }}
                  label={"תאריך"}
                  inputRef={ref}
                  {...restField}
                />
              )}
            />
            <div>{errors?.date?.message as string}</div>
          </LocalizationProvider>
          {!isViewMode && (
            <LoadingButton loading={loading} type="submit" variant="contained">
              {isEditMode ? "שמור" : "צור"}
            </LoadingButton>
          )}
        </Stack>
      </form>
      <div>{errors["date"]?.message}</div>
    </AppDialog>
  );
}

export default MatchDialog;
