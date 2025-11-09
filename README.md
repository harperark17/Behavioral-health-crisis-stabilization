# Behavioral Health Crisis Stabilization

A blockchain-based mental health platform that coordinates short-term crisis beds, psychiatric evaluations, and community service transitions for individuals experiencing behavioral health crises.

## Overview

This smart contract system provides a transparent and efficient framework for managing crisis stabilization services. It enables healthcare providers, psychiatric professionals, and community organizations to coordinate care for individuals in mental health crisis, ensuring proper tracking of bed placement, evaluations, care plans, and successful transitions to community-based services.

## Features

### Crisis Bed Management
- Real-time tracking of available crisis stabilization beds
- Bed placement coordination with automated availability checks
- Patient admission and discharge workflows
- Facility capacity monitoring

### Psychiatric Evaluation Scheduling
- Schedule and track psychiatric evaluations
- Maintain evaluation records with timestamps
- Link evaluations to specific patients and providers
- Track evaluation status and outcomes

### Stabilization Care Tracking
- Document care plans and interventions
- Monitor patient progress during stabilization
- Track medication management and therapy sessions
- Record safety assessments and risk levels

### Community Transition Coordination
- Plan and facilitate transitions to community services
- Track referrals to outpatient programs
- Monitor transition outcomes
- Coordinate with community service providers

### Outcome Measurement
- Track patient outcomes post-stabilization
- Measure readmission rates
- Monitor service quality metrics
- Generate reports for continuous improvement

## Contract Structure

### crisis-stabilization-coordinator
The main contract managing all crisis stabilization operations including:
- Bed placement and management
- Evaluation scheduling and tracking
- Care plan documentation
- Transition coordination
- Outcome tracking

## Data Types

- **Crisis Bed**: Facility information, capacity, availability status
- **Patient Admission**: Patient identifier, admission date, bed assignment
- **Psychiatric Evaluation**: Evaluator, patient, evaluation date, findings
- **Care Plan**: Treatment interventions, medications, therapy schedule
- **Transition Plan**: Discharge date, referrals, follow-up appointments
- **Outcome Record**: Success metrics, readmission data, quality indicators

## Technical Details

- **Platform**: Stacks Blockchain
- **Language**: Clarity
- **Token Standard**: None (administrative system)
- **Access Control**: Role-based permissions for providers and administrators

## Security & Privacy

- Patient data is pseudonymized using unique identifiers
- HIPAA-compliant data handling patterns
- Role-based access control for sensitive operations
- Audit trail for all care-related transactions

## Getting Started

### Prerequisites
- Clarinet CLI installed
- Node.js and npm
- Basic understanding of Clarity smart contracts

### Installation

```bash
# Clone the repository
git clone https://github.com/harperark17/Behavioral-health-crisis-stabilization.git

# Navigate to project directory
cd Behavioral-health-crisis-stabilization

# Install dependencies
npm install

# Check contract syntax
clarinet check
```

### Testing

```bash
# Run all tests
clarinet test

# Run specific test file
clarinet test tests/crisis-stabilization-coordinator_test.ts
```

## Usage

### Register a Crisis Bed
```clarity
(contract-call? .crisis-stabilization-coordinator register-crisis-bed 
  facility-id 
  bed-count 
  facility-type)
```

### Place Patient in Crisis Bed
```clarity
(contract-call? .crisis-stabilization-coordinator place-patient 
  patient-id 
  facility-id 
  admission-date)
```

### Schedule Psychiatric Evaluation
```clarity
(contract-call? .crisis-stabilization-coordinator schedule-evaluation 
  patient-id 
  evaluator-id 
  evaluation-date)
```

### Create Transition Plan
```clarity
(contract-call? .crisis-stabilization-coordinator create-transition-plan 
  patient-id 
  discharge-date 
  referral-services)
```

## Contributing

Contributions are welcome! Please follow these guidelines:
1. Fork the repository
2. Create a feature branch
3. Write tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## License

MIT License - see LICENSE file for details

## Support

For questions or support, please open an issue in the GitHub repository.

## Acknowledgments

Built with Clarity and Clarinet for the Stacks blockchain ecosystem.
