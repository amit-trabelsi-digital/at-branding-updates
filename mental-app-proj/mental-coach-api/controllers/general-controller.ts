import { NextFunction, Response, Request } from "express";
import AppError from "../utils/appError";
import GeneralData from "../models/general-data-model";
import crypto from "crypto";
import PersonalityGroup from "../models/personallity-group-model";

function getCryptoString(input: string) {
  return crypto.createHash("md5").update(input).digest("hex");
}

export const createTag = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const data = await GeneralData.findOne();

    // Handle the case where no document exists
    if (!data) {
      return next(new AppError("לא נמצא מידע", 404));
    }

    const { tag, personallityTag } = req.body;
    console.log(req.body);
    // Add the new tag
    if (tag) {
      console.log("tag", tag);
      if (data.tags.find((t) => t.label === tag)) {
        return next(new AppError("כבר קיים תג כזה", 400));
      }
      data.tags.push({ label: tag, value: getCryptoString(tag) });
    }

    if (personallityTag) {
      if (data.personallityTags.find((t) => t.label === personallityTag)) {
        return next(new AppError("כבר קיים תג כזה", 400));
      }
      console.log("personallityTag", personallityTag);
      data.personallityTags.push({ label: personallityTag, value: getCryptoString(personallityTag) });
    }

    // Save the updated document
    const result = await data.save();

    res.status(201).json(result);
  } catch (err) {
    console.log(err);
    next(err);
  }
};

export const createPersonnalityGroup = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    console.log(req.body);
    const personalityGroup = new PersonalityGroup(req.body);
    const savedPersonallityGroup = await personalityGroup.save();
    res.status(201).json(savedPersonallityGroup);
  } catch (error) {
    console.log(error);
    next(error);
  }
};

export const getTags = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const result = await GeneralData.findOne({});

    res.status(201).json(result);
  } catch (err) {
    next(err);
  }
};

export const deleteTag = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { value, item } = req.query as { value?: string; item?: string };

    if (!value) {
      return next(new AppError("Value parameter is required", 400));
    }

    const generalDataObject = await GeneralData.findOne({});
    if (!generalDataObject) {
      return next(new AppError("GeneralData not found", 404));
    }

    const selectedArrayKey = item || "tags";
    const selectedArray = generalDataObject[selectedArrayKey];

    if (!Array.isArray(selectedArray)) {
      return next(new AppError(`The property '${selectedArrayKey}' is not a valid array`, 400));
    }

    const index = selectedArray.findIndex((i: { value: string }) => i.value === value);

    if (index === -1) {
      return next(new AppError(`No tag found with value '${value}'`, 404));
    }

    selectedArray.splice(index, 1);
    await generalDataObject.save();

    res.status(200).json({
      status: "success",
      data: generalDataObject,
    });
  } catch (error) {
    next(error);
  }
};

export const updateGeneralData = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    let data = await GeneralData.findOne();
    if (!data) {
      return next(new AppError("לא נמצא מידע", 404));
    }

    if (req.body.fileType && req.body.fileData) {
      const { fileType, fileData } = req.body;

      if (fileType === "profileAudioFile") {
        data.profileAudioFile = {
          fileType: fileType,
          fileData: fileData, // Assuming fileData has {name, path} structure
        };
      } else if (fileType === "goalsAudioFile") {
        data.goalsAudioFile = {
          fileType: fileType,
          fileData: fileData, // Assuming fileData has {name, path} structure
        };
      }
    }
    const result = await data.save();
    res.status(200).json(result);
  } catch (error) {
    console.log(error);
    next(error);
  }
};

export const getGeneralDataForUser = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const data = await GeneralData.findOne().select("goalsAudioFile profileAudioFile");
    console.log("data====--->>>", data);
    if (!data) {
      return next(new AppError("לא נמצא מידע", 404));
    }

    res.status(200).json(data);
  } catch (error) {
    console.log(error);
    next(error);
  }
};
