#!/usr/bin/env node
import fetch from 'node-fetch';
import inquirer from 'inquirer';
import colors from 'colors';

const API_URL = process.env.API_URL || 'http://localhost:5001';

console.log('\n🔐 Twilio OTP Testing Script'.cyan.bold);
console.log('================================\n'.cyan);

async function checkStatus() {
  try {
    const response = await fetch(`${API_URL}/api/otp/status`);
    const data = await response.json();
    
    console.log('📡 Service Status:'.yellow);
    console.log(`   Status: ${data.status === 'active' ? '✅ Active'.green : '❌ Inactive'.red}`);
    console.log(`   Has Credentials: ${data.hasCredentials ? '✅ Yes'.green : '❌ No'.red}`);
    console.log(`   Environment: ${data.environment}\n`);
    
    return data;
  } catch (error) {
    console.error('❌ Failed to check service status:'.red, error.message);
    return null;
  }
}

async function sendOTP(phoneNumber, email) {
  try {
    console.log(`\n📤 Sending OTP to ${phoneNumber}...`.yellow);
    
    const response = await fetch(`${API_URL}/api/otp/send`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ phoneNumber, email })
    });
    
    const data = await response.json();
    
    if (response.ok) {
      console.log('✅ OTP sent successfully!'.green);
      console.log(`   Phone: ${data.phoneNumber}`);
      console.log(`   Expires in: ${data.expiresIn} seconds`);
      
      if (data.development) {
        console.log(`\n🔑 Development Mode - Test Code: ${data.testCode}`.cyan.bold);
      }
      
      return data;
    } else {
      console.error('❌ Failed to send OTP:'.red, data.message);
      return null;
    }
  } catch (error) {
    console.error('❌ Error sending OTP:'.red, error.message);
    return null;
  }
}

async function verifyOTP(phoneNumber, code) {
  try {
    console.log(`\n🔍 Verifying OTP...`.yellow);
    
    const response = await fetch(`${API_URL}/api/otp/verify`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ phoneNumber, code })
    });
    
    const data = await response.json();
    
    if (response.ok) {
      console.log('✅ OTP verified successfully!'.green);
      console.log('\n👤 User Details:'.cyan);
      console.log(`   Name: ${data.user.firstName} ${data.user.lastName}`);
      console.log(`   Email: ${data.user.email}`);
      console.log(`   Phone: ${data.user.firebasePhoneNumber}`);
      console.log(`   Role: ${data.user.role}`);
      console.log('\n🎫 Firebase Custom Token:'.cyan);
      console.log(`   ${data.token.substring(0, 50)}...`.gray);
      
      return data;
    } else {
      console.error('❌ Failed to verify OTP:'.red, data.message);
      return null;
    }
  } catch (error) {
    console.error('❌ Error verifying OTP:'.red, error.message);
    return null;
  }
}

async function main() {
  // Check service status
  const status = await checkStatus();
  
  if (!status) {
    console.log('\n⚠️  Cannot connect to API server'.yellow);
    process.exit(1);
  }
  
  // Get test parameters
  const answers = await inquirer.prompt([
    {
      type: 'list',
      name: 'action',
      message: 'What would you like to test?',
      choices: [
        { name: '📤 Send OTP', value: 'send' },
        { name: '🔍 Verify OTP', value: 'verify' },
        { name: '🔄 Full Flow (Send + Verify)', value: 'full' },
        { name: '❌ Exit', value: 'exit' }
      ]
    }
  ]);
  
  if (answers.action === 'exit') {
    console.log('\n👋 Goodbye!'.cyan);
    process.exit(0);
  }
  
  const phoneAnswer = await inquirer.prompt([
    {
      type: 'input',
      name: 'phoneNumber',
      message: 'Enter phone number:',
      default: '0501234567',
      validate: (input) => {
        if (!input) return 'Phone number is required';
        return true;
      }
    }
  ]);
  
  if (answers.action === 'send' || answers.action === 'full') {
    const emailAnswer = await inquirer.prompt([
      {
        type: 'input',
        name: 'email',
        message: 'Enter email (optional):',
        default: ''
      }
    ]);
    
    const otpData = await sendOTP(phoneAnswer.phoneNumber, emailAnswer.email || undefined);
    
    if (answers.action === 'full' && otpData) {
      const codeAnswer = await inquirer.prompt([
        {
          type: 'input',
          name: 'code',
          message: 'Enter the OTP code:',
          default: otpData.testCode || '',
          validate: (input) => {
            if (!input) return 'Code is required';
            if (input.length !== 6) return 'Code must be 6 digits';
            return true;
          }
        }
      ]);
      
      await verifyOTP(phoneAnswer.phoneNumber, codeAnswer.code);
    }
  } else if (answers.action === 'verify') {
    const codeAnswer = await inquirer.prompt([
      {
        type: 'input',
        name: 'code',
        message: 'Enter the OTP code:',
        validate: (input) => {
          if (!input) return 'Code is required';
          if (input.length !== 6) return 'Code must be 6 digits';
          return true;
        }
      }
    ]);
    
    await verifyOTP(phoneAnswer.phoneNumber, codeAnswer.code);
  }
  
  // Ask if want to continue
  const continueAnswer = await inquirer.prompt([
    {
      type: 'confirm',
      name: 'continue',
      message: 'Do you want to test again?',
      default: true
    }
  ]);
  
  if (continueAnswer.continue) {
    await main();
  } else {
    console.log('\n👋 Goodbye!'.cyan);
    process.exit(0);
  }
}

// Start the script
main().catch(error => {
  console.error('\n❌ Fatal error:'.red, error);
  process.exit(1);
});