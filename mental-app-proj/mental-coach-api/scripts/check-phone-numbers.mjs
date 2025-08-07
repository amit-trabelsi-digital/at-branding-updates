#!/usr/bin/env node
import mongoose from 'mongoose';
import dotenv from 'dotenv';
import User from './user-model.mjs';
import colors from 'colors';
import { readFileSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';

const __dirname = dirname(fileURLToPath(import.meta.url));
dotenv.config({ path: join(__dirname, '..', '.env') });

// Try various MongoDB URI environment variables
let mongoUri = process.env.MONGO_URI_DEV || process.env.MONGODB_URI || process.env.DATABASE || process.env.MONGO_URI;
const dbName = process.env.DB_NAME || 'mental-coach';

if (!mongoUri) {
  try {
    const envContent = readFileSync(join(__dirname, '..', '.env'), 'utf-8');
    const mongoLine = envContent.split('\n').find(line => 
      line.startsWith('MONGO_URI_DEV=') || 
      line.startsWith('DATABASE=') || 
      line.startsWith('MONGODB_URI=')
    );
    if (mongoLine) {
      mongoUri = mongoLine.split('=')[1].trim().replace(/['"]/g, '');
    }
  } catch (e) {
    console.log('⚠️ Could not read .env file'.yellow);
  }
}

if (!mongoUri) {
  console.error('❌ MongoDB URI not found. Please ensure MONGO_URI_DEV is set in .env file'.red);
  process.exit(1);
}

async function checkPhoneNumbers() {
  try {
    console.log('🔍 Connecting to MongoDB...'.cyan);
    console.log(`   URI: ${mongoUri.replace(/\/\/[^:]+:[^@]+@/, '//<credentials>@')}`.gray);
    console.log(`   DB: ${dbName}`.gray);
    
    await mongoose.connect(mongoUri, {
      dbName: dbName
    });
    console.log('✅ Connected to MongoDB'.green);

    // Find all users with phone numbers
    const users = await User.find({
      $or: [
        { phoneNumber: { $exists: true, $ne: null, $ne: '' } },
        { firebasePhoneNumber: { $exists: true, $ne: null, $ne: '' } },
        { phone: { $exists: true, $ne: null, $ne: '' } }
      ]
    }).select('name email phoneNumber firebasePhoneNumber phone allowedAuthMethods');

    console.log(`\n📱 Found ${users.length} users with phone numbers:\n`.yellow);

    users.forEach((user, index) => {
      console.log(`${index + 1}. ${user.name || 'No Name'}`.cyan);
      console.log(`   Email: ${user.email || 'N/A'}`);
      console.log(`   phoneNumber: ${user.phoneNumber || 'N/A'}`.green);
      console.log(`   firebasePhoneNumber: ${user.firebasePhoneNumber || 'N/A'}`.green);
      console.log(`   phone: ${user.phone || 'N/A'}`.green);
      
      const authMethods = user.allowedAuthMethods || {};
      console.log(`   SMS Auth Allowed: ${authMethods.sms ? '✅ Yes'.green : '❌ No'.red}`);
      console.log('   ---');
    });

    // Test phone number search
    console.log('\n🔍 Testing phone number search...'.yellow);
    const testNumbers = ['0506362008', '0559563433', '+972506362008', '972506362008'];
    
    for (const testNum of testNumbers) {
      const phoneVariants = [
        testNum,
        testNum.replace('+972', '0'),
        testNum.replace('972', '0'),
        testNum.startsWith('0') ? '+972' + testNum.substring(1) : testNum,
        testNum.startsWith('0') ? '972' + testNum.substring(1) : testNum,
      ];
      
      const user = await User.findOne({
        $or: [
          { firebasePhoneNumber: { $in: phoneVariants } },
          { phoneNumber: { $in: phoneVariants } },
          { phone: { $in: phoneVariants } }
        ]
      });
      
      if (user) {
        console.log(`✅ Found user for ${testNum}: ${user.name || user.email}`.green);
      } else {
        console.log(`❌ No user found for ${testNum}`.red);
      }
    }

    // Enable SMS for all users with phone numbers (optional)
    console.log('\n💡 To enable SMS for all users with phone numbers, uncomment the code below'.yellow);
    
    // Uncomment to enable SMS for all users with phone numbers:
    /*
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
          'allowedAuthMethods.sms': true
        }
      }
    );
    console.log(`Updated ${updateResult.modifiedCount} users to allow SMS authentication`.green);
    */

  } catch (error) {
    console.error('❌ Error:'.red, error);
  } finally {
    await mongoose.disconnect();
    console.log('\n👋 Disconnected from MongoDB'.gray);
  }
}

checkPhoneNumbers();