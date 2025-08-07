/* eslint-disable @typescript-eslint/no-explicit-any */
import { appFetch } from "../services/fetch";
import { Position } from "./types";

export const simpleDateFormatter = (stringDate: string | Date) => {
  const originalDate = new Date(stringDate);
  const formattedDate = originalDate.toLocaleDateString("he-IL", {
    day: "numeric",
    month: "numeric",
    year: "2-digit",
  });
  return formattedDate;
};

export const phoneNumberFormatter = (phoneNumber: string) => {
  if (!phoneNumber) return;
  if (phoneNumber && phoneNumber[1] !== "5") {
    return phoneNumber.slice(0, 2) + "-" + phoneNumber.slice(2);
  }
  return phoneNumber.slice(0, 3) + "-" + phoneNumber.slice(3);
};

export const localHebrewDateFormmater = (currentDate: string | Date) => {
  const date = new Date(currentDate);
  const hebrewDate = date.toLocaleDateString("he-IL", {
    year: "numeric",
    month: "long",
    day: "numeric",
    weekday: "long",
  });
  return hebrewDate;
};

export function fixedTeamArrayFunction(
  data: { _id: string; name: string }[] | undefined | any
) {
  if (!Array.isArray(data)) {
    return [];
  }
  const fixedDataArray = data.map((team: { _id: string; name: string }) => {
    return { value: team._id, label: team.name };
  });
  return fixedDataArray;
}

export const renderResponseState = (expression: string): string => {
  switch (expression) {
    case "before":
      return "לפני אימון";
    case "after":
      return "אחרי אימון";
    case "inTime":
      return "במהלך האימון";
    default:
      return "מצב לא ידוע"; // A fallback string for unmatched goals
  }
};

export const ToolTipPopsitionFullList = (arr: Position[]): string => {
  let toolTipString = "";

  arr?.forEach((item: Position, index: number) => {
    const comma = index < arr.length - 1 ? " , " : " ";
    toolTipString += item.label + comma;
  });

  return toolTipString;
};

export async function deleteItem<T extends { _id: string }>(
  row: T,
  baseUrl: string,
  onSuccess: () => void,
  onError: (err: Error) => void
) {
  try {
    const res = await appFetch(`${baseUrl}/${row._id}`, {
      method: "DELETE",
    });
    if (!res.ok) throw new Error();
    onSuccess();
  } catch (err: any) {
    onError(err);
  } finally {
    console.log("test");
  }
}

export const isAudioFile = (file: File): boolean => {
  // Check MIME type (most reliable method)
  console.log(file);
  if (file.type.startsWith("audio/")) {
    return true;
  }

  // Fallback: check file extension
  const validExtensions = [
    ".mp3",
    ".wav",
    ".ogg",
    ".m4a",
    ".flac",
    ".aac",
    ".wma",
    ".aiff",
    ".alac",
    ".opus",
    ".amr",
  ];

  const fileName = file.name.toLowerCase();
  return validExtensions.some((ext) => fileName.endsWith(ext));
};
