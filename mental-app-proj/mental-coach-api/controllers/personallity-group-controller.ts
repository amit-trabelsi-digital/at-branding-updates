import { Request, Response, NextFunction } from "express";
import PersonalityGroup from "../models/personallity-group-model";
// Create a personallityGroupAndResponse
export const createPersonallityGroup = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    console.log(req.body);
    const personallityGroupAndResponse = new PersonalityGroup(req.body);
    const savedPersonallityGroupAndResponse = await personallityGroupAndResponse.save();
    res.status(201).json(savedPersonallityGroupAndResponse);
  } catch (error) {
    console.log(error);
    next(error);
  }
};

// Get all personallityGroups
export const getAllPersonallityGroups = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const personallityGroups = await PersonalityGroup.find();
    res.status(200).json(personallityGroups);
  } catch (error) {
    next(error);
  }
};

// Get a personallityGroupAndResponse by ID
export const getPersonallityGroupById = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { id } = req.params;
    const personallityGroupAndResponse = await PersonalityGroup.findById(id);

    if (!personallityGroupAndResponse) {
      res.status(404).json({ message: "PersonalityGroup not found" });
      return;
    }

    res.status(200).json(personallityGroupAndResponse);
  } catch (error) {
    next(error);
  }
};

// Update a personallityGroupAndResponse
export const updatePersonallityGroup = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { id } = req.params;
    const updatedPersonallityGroup = await PersonalityGroup.findByIdAndUpdate(id, req.body, { new: true, runValidators: true });

    if (!updatedPersonallityGroup) {
      res.status(404).json({ message: "PersonalityGroup not found" });
      return;
    }

    res.status(200).json(updatedPersonallityGroup);
  } catch (error) {
    next(error);
  }
};

// Delete a personallityGroupAndResponse
export const deletePersonallityGroup = async (req: Request, res: Response, next: NextFunction): Promise<void> => {
  try {
    const { id } = req.params;
    const deletedPersonallityGroup = await PersonalityGroup.findByIdAndDelete(id);

    if (!deletedPersonallityGroup) {
      res.status(404).json({ message: "PersonalityGroup not found" });
      return;
    }

    res.status(200).json({ message: "PersonalityGroup deleted successfully" });
  } catch (error) {
    next(error);
  }
};
