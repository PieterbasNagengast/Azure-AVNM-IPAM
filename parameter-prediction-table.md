# IPAM Parameter Prediction Table

## Current Configuration Analysis
- **Azure CIDR**: 172.16.0.0/12 (current region CIDR size: /16)
- **Region CIDR Split Size**: 21
- **Total Subnets Available per Region**: 2^(21-16) = 32 subnets

## Parameter Impact Prediction Table

| Scenario                     | Platform & App Split (%) | Connectivity & Identity Split (%) | Corp & Online Split (%) | Platform LZ Count | Platform Connectivity Count | Platform Identity Count | Application LZ Count | Application Corp Count | Application Online Count |
| ---------------------------- | ------------------------ | --------------------------------- | ----------------------- | ----------------- | --------------------------- | ----------------------- | -------------------- | ---------------------- | ------------------------ |
| **Current - North Europe**   | 10                       | 50                                | 75                      | 3                 | 4                           | 4                       | 29                   | 22                     | 7                        |
| **Current - Sweden Central** | 10                       | 50                                | 75                      | 3                 | 4                           | 4                       | 29                   | 22                     | 7                        |
| **Balanced**                 | 50                       | 50                                | 50                      | 16                | 4                           | 4                       | 16                   | 8                      | 8                        |
| **Platform Heavy**           | 75                       | 30                                | 25                      | 24                | 2                           | 6                       | 8                    | 2                      | 6                        |
| **Application Heavy**        | 25                       | 70                                | 80                      | 8                 | 6                           | 2                       | 24                   | 19                     | 5                        |
| **Connectivity Focused**     | 40                       | 80                                | 40                      | 13                | 6                           | 2                       | 19                   | 8                      | 11                       |
| **Identity Focused**         | 40                       | 20                                | 40                      | 13                | 2                           | 6                       | 19                   | 8                      | 11                       |
| **Corp Heavy**               | 30                       | 40                                | 90                      | 10                | 3                           | 5                       | 22                   | 20                     | 2                        |
| **Online Heavy**             | 30                       | 40                                | 10                      | 10                | 3                           | 5                       | 22                   | 2                      | 20                       |
| **Equal Distribution**       | 33                       | 50                                | 50                      | 11                | 4                           | 4                       | 21                   | 11                     | 10                       |
| **Minimal Platform**         | 5                        | 60                                | 60                      | 2                 | 5                           | 3                       | 30                   | 18                     | 12                       |
| **Maximum Platform**         | 95                       | 40                                | 30                      | 30                | 3                           | 5                       | 2                    | 1                      | 1                        |

## Formula Explanations

### Base Calculations
- **Total Subnets**: 2^(RegionCIDRsplitSize - currentRegionCIDRsize) = 2^(21-16) = 32
- **Platform LZ Count**: max(1, 32 × PlatformAndApplicationSplitFactor / 100)
- **Application LZ Count**: 32 - Platform LZ Count

### Platform Subdivisions (Fixed at 8 total)
- **Platform Connectivity Count**: max(1, 8 × ConnectivityAndIdentitySplitFactor / 100)
- **Platform Identity Count**: 8 - Platform Connectivity Count

### Application Subdivisions
- **Application Corp Count**: max(1, Application LZ Count × CorpAndOnlineSplitFactor / 100)
- **Application Online Count**: Application LZ Count - Application Corp Count

## Key Insights

1. **Platform & Application Split Factor** has the most significant impact on resource distribution
2. **Connectivity & Identity Split** only affects the 8 platform sub-CIDRs (not the main platform count)
3. **Corp & Online Split** proportionally divides the application subnets
4. Minimum values are enforced (max(1, calculation)) to ensure at least 1 subnet per category
5. Changes to RegionCIDRsplitSize would dramatically affect total available subnets (doubling/halving with each increment/decrement)

## Recommendations

- **For development environments**: Use lower Platform split (10-20%) to maximize application subnets
- **For production environments**: Use higher Platform split (30-50%) for better governance and connectivity
- **For multi-tenant scenarios**: Balance Corp/Online split based on tenant distribution requirements
- **For security-focused deployments**: Increase Platform split and Identity allocation

## Region CIDR Split Size Impact Analysis

The **Region CIDR Split Size** parameter has the most dramatic impact on available subnets. Here's how different values affect the total subnet count and subsequent allocations:

### Region CIDR Split Size Comparison Table

| Split Size | Total Subnets | Description          | Use Case                   |
| ---------- | ------------- | -------------------- | -------------------------- |
| /17        | 2             | Very large subnets   | Enterprise-wide allocation |
| /18        | 4             | Large subnets        | Major business units       |
| /19        | 8             | Medium-large subnets | Regional divisions         |
| /20        | 16            | Medium subnets       | Department-level           |
| /21        | 32            | **Current setting**  | Workload-level             |
| /22        | 64            | Small subnets        | Application-level          |
| /23        | 128           | Very small subnets   | Micro-services             |
| /24        | 256           | Minimal subnets      | Individual services        |

### Detailed Calculations by Region CIDR Split Size

#### Split Size /19 (8 Total Subnets) - 50% Platform Split Example
| Category               | Count | Calculation               |
| ---------------------- | ----- | ------------------------- |
| Platform LZ            | 4     | max(1, 8 × 50% / 100) = 4 |
| Application LZ         | 4     | 8 - 4 = 4                 |
| Platform Connectivity  | 4     | max(1, 8 × 50% / 100) = 4 |
| Platform Identity      | 4     | 8 - 4 = 4                 |
| Application Corp (75%) | 3     | max(1, 4 × 75% / 100) = 3 |
| Application Online     | 1     | 4 - 3 = 1                 |

#### Split Size /20 (16 Total Subnets) - 50% Platform Split Example
| Category               | Count | Calculation                |
| ---------------------- | ----- | -------------------------- |
| Platform LZ            | 8     | max(1, 16 × 50% / 100) = 8 |
| Application LZ         | 8     | 16 - 8 = 8                 |
| Platform Connectivity  | 4     | max(1, 8 × 50% / 100) = 4  |
| Platform Identity      | 4     | 8 - 4 = 4                  |
| Application Corp (75%) | 6     | max(1, 8 × 75% / 100) = 6  |
| Application Online     | 2     | 8 - 6 = 2                  |

#### Split Size /21 (32 Total Subnets) - 50% Platform Split Example
| Category               | Count | Calculation                 |
| ---------------------- | ----- | --------------------------- |
| Platform LZ            | 16    | max(1, 32 × 50% / 100) = 16 |
| Application LZ         | 16    | 32 - 16 = 16                |
| Platform Connectivity  | 4     | max(1, 8 × 50% / 100) = 4   |
| Platform Identity      | 4     | 8 - 4 = 4                   |
| Application Corp (75%) | 12    | max(1, 16 × 75% / 100) = 12 |
| Application Online     | 4     | 16 - 12 = 4                 |

#### Split Size /22 (64 Total Subnets) - 50% Platform Split Example
| Category               | Count | Calculation                 |
| ---------------------- | ----- | --------------------------- |
| Platform LZ            | 32    | max(1, 64 × 50% / 100) = 32 |
| Application LZ         | 32    | 64 - 32 = 32                |
| Platform Connectivity  | 4     | max(1, 8 × 50% / 100) = 4   |
| Platform Identity      | 4     | 8 - 4 = 4                   |
| Application Corp (75%) | 24    | max(1, 32 × 75% / 100) = 24 |
| Application Online     | 8     | 32 - 24 = 8                 |

#### Split Size /23 (128 Total Subnets) - 50% Platform Split Example
| Category               | Count | Calculation                  |
| ---------------------- | ----- | ---------------------------- |
| Platform LZ            | 64    | max(1, 128 × 50% / 100) = 64 |
| Application LZ         | 64    | 128 - 64 = 64                |
| Platform Connectivity  | 4     | max(1, 8 × 50% / 100) = 4    |
| Platform Identity      | 4     | 8 - 4 = 4                    |
| Application Corp (75%) | 48    | max(1, 64 × 75% / 100) = 48  |
| Application Online     | 16    | 64 - 48 = 16                 |

### Cross-Parameter Impact Matrix (Various Split Sizes with Current 10% Platform Split)

| Split Size | Total | Platform | Application | App Corp (75%) | App Online |
| ---------- | ----- | -------- | ----------- | -------------- | ---------- |
| /17        | 2     | 1        | 1           | 1              | 0          |
| /18        | 4     | 1        | 3           | 2              | 1          |
| /19        | 8     | 1        | 7           | 5              | 2          |
| /20        | 16    | 2        | 14          | 11             | 3          |
| /21        | 32    | 3        | 29          | 22             | 7          |
| /22        | 64    | 6        | 58          | 44             | 14         |
| /23        | 128   | 13       | 115         | 86             | 29         |
| /24        | 256   | 26       | 230         | 173            | 57         |

### Region CIDR Split Size Recommendations

- **/17-/18**: Only for very large organizations with minimal subdivision needs
- **/19-/20**: Suitable for large enterprises with major business unit divisions
- **/21**: **Current setting** - Good balance for most enterprise workloads
- **/22**: Ideal for organizations with many applications and microservices
- **/23-/24**: For highly granular subdivision and container-heavy architectures

### Important Considerations

1. **Subnet Size**: Smaller split sizes mean larger individual subnets but fewer of them
2. **Flexibility**: Larger split sizes provide more allocation flexibility
3. **Management Overhead**: More subnets mean more management complexity
4. **Future Growth**: Consider growth projections when selecting split size
5. **Network Segmentation**: Security requirements may drive need for more granular splits
