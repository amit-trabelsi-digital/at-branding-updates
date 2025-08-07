#!/usr/bin/env node
import mongoose from 'mongoose';
import dotenv from 'dotenv';
import User from './user-model.mjs';
import colors from 'colors';
import inquirer from 'inquirer';

dotenv.config();

const mongoUri = process.env.MONGO_URI_DEV || process.env.MONGODB_URI || process.env.DATABASE;
const dbName = process.env.DB_NAME || 'mental-coach';

if (!mongoUri) {
  console.error('❌ MongoDB URI not found in environment variables'.red);
  process.exit(1);
}

async function enableSMSAuth() {
  try {
    console.log('🔍 Connecting to MongoDB...'.cyan);
    await mongoose.connect(mongoUri, { dbName });
    console.log('✅ Connected to MongoDB'.green);

    // Find all users with phone numbers
    const users = await User.find({
      $or: [
        { phoneNumber: { $exists: true, $ne: null, $ne: '' } },
        { firebasePhoneNumber: { $exists: true, $ne: null, $ne: '' } },
        { phone: { $exists: true, $ne: null, $ne: '' } }
      ]
    }).select('name email phoneNumber firebasePhoneNumber phone allowedAuthMethods');

    console.log(`\n📱 Found ${users.length} users with phone numbers`.yellow);

    if (users.length === 0) {
      console.log('No users with phone numbers found'.gray);
      return;
    }

    // Show users
    users.forEach((user, index) => {
      const phone = user.phoneNumber || user.firebasePhoneNumber || user.phone;
      const smsEnabled = user.allowedAuthMethods?.sms || false;
      console.log(`${index + 1}. ${user.name || user.email} - ${phone} - SMS: ${smsEnabled ? '✅' : '❌'}`);
    });

    // Ask to enable SMS for all
    const { enableAll } = await inquirer.prompt({
      name: 'enableAll',
      type: 'confirm',
      message: 'Enable SMS authentication for all users with phone numbers?',
      default: true
    });

    if (enableAll) {
      const updateResult = await User.updateMany(
        {
          $or: [
            { phoneNumber: { $exists: true, $ne: null, $ne: '' } },
            { firebasePhoneNumber: { $exists: true, $ne: null, $ne: '' } },
            { phone: { $exists: true, $ne: null, $ne: '' } }
          ]
        },
        {
          $set: {
            'allowedAuthMethods.sms': true,
            'allowedAuthMethods.email': true,
            'allowedAuthMethods.google': true,
            'allowedAuthMethods.apple': true
          }
        }
      );
      console.log(`\n✅ Updated ${updateResult.modifiedCount} users to allow SMS authentication`.green);
    } else {
      // Enable for specific users
      const { selectedUsers } = await inquirer.prompt({
        name: 'selectedUsers',
        type: 'checkbox',
        message: 'Select users to enable SMS for:',
        choices: users.map((user, index) => ({
          name: `${user.name || user.email} - ${user.phoneNumber || user.firebasePhoneNumber || user.phone}`,
          value: user._id
        }))
      });

      if (selectedUsers.length > 0) {
        const updateResult = await User.updateMany(
          { _id: { $in: selectedUsers } },
          {
            $set: {
              'allowedAuthMethods.sms': true
            }
          }
        );
        console.log(`\n✅ Updated ${updateResult.modifiedCount} users to allow SMS authentication`.green);
      }
    }

    // Show test numbers
    console.log('\n📱 Test with these numbers:'.cyan);
    const testUsers = await User.find({
      'allowedAuthMethods.sms': true,
      $or: [
        { phoneNumber: { $exists: true, $ne: null, $ne: '' } },
        { firebasePhoneNumber: { $exists: true, $ne: null, $ne: '' } },
        { phone: { $exists: true, $ne: null, $ne: '' } }
      ]
    }).limit(3);

    testUsers.forEach(user => {
      const phone = user.phoneNumber || user.firebasePhoneNumber || user.phone;
      console.log(`   ${user.name || user.email}: ${phone}`.green);
    });

  } catch (error) {
    console.error('❌ Error:'.red, error);
  } finally {
    await mongoose.disconnect();
    console.log('\n👋 Disconnected from MongoDB'.gray);
  }
}

enableSMSAuth();