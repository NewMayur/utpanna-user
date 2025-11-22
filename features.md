This is a comprehensive **Product Requirements Document (PRD) and Technical Specification**. It is written for a Flutter developer to implement the feature immediately using a local JSON data source while ensuring the existing backend endpoints for "Joining a Deal" are integrated correctly.

---

# Feature: Crop Protection & Nutrition Combo Builder

**Version:** 1.0
**Status:** Ready for Development

## 1. Executive Summary

We are introducing a "Group Buying" discovery tool. Farmers select their Crop and Objective (e.g., "Cotton" + "Growth") and are presented with a **Recommended Product Combo**. They can view the price per Acre or per Pump.

- **Happy Path:** User views the recommended combo -> Clicks "Join Deal" -> API called with the existing Deal UUID.
- **Customization Path:** User customizes quantities to estimate their budget. _Note: Custom combos cannot be turned into new deals dynamically due to backend constraints. Customization is purely a calculator._

---

## 2. Technical Architecture

### 2.1 Data Source (Mock Data)

Create a file `assets/json/farming_data.json`. This file drives the UI until a "Combo API" is built.

**JSON Structure (Copy this exactly):**

```json
{
  "crops": [
    {
      "id": "c_cotton",
      "name": "Cotton",
      "image_asset": "assets/crops/cotton.png"
    },
    {
      "id": "c_soybean",
      "name": "Soybean",
      "image_asset": "assets/crops/soybean.png"
    },
    {
      "id": "c_chana",
      "name": "Chana",
      "image_asset": "assets/crops/chana.png"
    }
  ],
  "objectives": [
    { "id": "obj_growth", "name": "Vegetative Growth" },
    { "id": "obj_flower", "name": "Flowering Stage" },
    { "id": "obj_pest", "name": "Pest Control" }
  ],
  "products": [
    {
      "id": "p_nitro",
      "name": "NitroBoost Fertilizer",
      "category": "Fertilizers",
      "price": 500,
      "unit": "1 L",
      "active_deal_uuid": "uuid-prod-nitro-001"
    },
    {
      "id": "p_pestx",
      "name": "PestX Insecticide",
      "category": "Insecticides",
      "price": 850,
      "unit": "500 ml",
      "active_deal_uuid": null
    },
    {
      "id": "p_fungi",
      "name": "FungiKill",
      "category": "Fungicide",
      "price": 300,
      "unit": "250 g",
      "active_deal_uuid": null
    }
  ],
  "recommendations": [
    {
      "crop_id": "c_cotton",
      "objective_id": "obj_growth",
      "deal_uuid": "DEAL-COTTON-GROWTH-2024",
      "combo_title": "Cotton Growth Special",
      "items": [
        { "product_id": "p_nitro", "qty_acre": 1.0, "qty_pump": 0.1 },
        { "product_id": "p_pestx", "qty_acre": 0.5, "qty_pump": 0.05 }
      ]
    }
  ]
}
```

### 2.2 Backend Integration (Existing)

- **Method:** `POST`
- **Endpoint:** `{{url}}/deals/{deal_uuid}/participate`
- **Payload:**
  ```json
  {
    "name": "User Name",
    "address": "User Address, Village, Pincode"
  }
  ```
- **Trigger:** Called only when the user confirms the "Join Deal" action on the Recommended Combo.

---

## 3. UI Specifications & Logic Flow

### Screen 1: Choose Your Crops

**Route:** `/combo/select-crop`

- **UI:** Grid view of crops from JSON `crops`.
- **Action:** Tapping a crop saves `selectedCropId` and navigates to Screen 2.

### Screen 2: Choose Objective

**Route:** `/combo/select-objective`

- **UI:** List view of objectives from JSON `objectives`.
- **Action:** Tapping an objective saves `selectedObjectiveId`.
- **Logic:** Search `recommendations` array in JSON for a match on `crop_id` + `objective_id`.
  - _If found:_ Navigate to Screen 3.
  - _If not found:_ Show snackbar "No active deals for this combination."

### Screen 3: Products & Recommended Combo (The "Deal" Page)

**Route:** `/combo/view-deal`

- **State:** Needs `isByAcre` (Boolean, default True).
- **Header:** Title is `recommendations.combo_title`.
- **List Section:**
  - Group products by Category.
  - **Individual Deal Link:** Check `product.active_deal_uuid`. If not null, show a link "View Single Product Deal".
  - _Action:_ Clicking that link navigates to your existing product deal page (out of scope, but leave the tap handler ready).
- **Combo Summary Section (Bottom Card):**
  - **Toggle:** [By Acre | By Pump]
  - **Calculation Logic:**
    - If `By Acre`: Sum of (`item.qty_acre` \* `product.price`).
    - If `By Pump`: Sum of (`item.qty_pump` \* `product.price`).
  - **Display:** List items with calculated Qty and Price. Show Total Cost.
- **Buttons:**
  1.  **"Customize Combo"** -> Navigates to Screen 4.
  2.  **"Join Deal"** -> Opens Confirmation Modal (See Section 4).

### Screen 4: Customize Combo (The "Calculator" Page)

**Route:** `/combo/customize`

- **Purpose:** Budget estimation tool.
- **UI:** Re-list the items with `+` and `-` counters.
- **Logic:**
  - Initialize quantities from the Recommended values.
  - User modifies quantities -> Update Total Price in real-time.
  - **Constraint Handling:**
    - Add a visible banner at the top: _"Customization is for cost estimation only. Deals are available on standard packs."_
- **Buttons:**
  - **"Join Deal" (Modified Behavior):** Since we cannot create a custom deal on the backend, this button must trigger an alert:
    - _Alert Title:_ "Reset to Standard Deal?"
    - _Alert Body:_ "Group deals are only available for the recommended combo. Do you want to discard changes and join the standard deal?"
    - _Yes:_ Proceed to Confirmation Modal (using original `deal_uuid`).
    - _No:_ Stay on screen (Calculated view).

---

## 4. The "Join Deal" Modal & API Integration

This logic applies when the user commits to the deal.

1.  **UI:** A BottomSheet or Dialog.
2.  **Content:**
    - "You are joining the **[Combo Title]** Group Deal."
    - "Total Estimated Cost: ₹[Amount]"
    - **Input Fields:** Name (Text), Address (Multiline Text).
3.  **Action:** User clicks "Confirm & Join".
4.  **Developer Logic:**
    ```dart
    // 1. Show Loading Indicator
    // 2. Call API
    try {
      final response = await http.post(
        Uri.parse('$BASE_URL/deals/$RECOMMENDED_DEAL_UUID/participate'),
        body: {
          "name": nameController.text,
          "address": addressController.text
        }
      );
      if (response.statusCode == 200) {
        // Show Success Dialog: "Participation Confirmed! We will notify you when the deal closes."
        // Navigate to Home
      }
    } catch (e) {
      // Show Error
    }
    ```

---

## 5. Developer Implementation Steps (Checklist)

1.  **Setup Models:**
    - Create Dart models for `Product`, `Crop`, `Objective`, and `Recommendation` (parsing the JSON structure provided in 2.1).
2.  **State Management (Provider Recommended):**
    - Create `ComboBuilderProvider`.
    - Variables: `selectedCrop`, `selectedObjective`, `currentRecommendation`, `isByAcre` (bool), `customQuantities` (Map<String, double>).
    - Method `calculateTotal()`: Loops through products, checks `isByAcre`, multiplies price \* qty.
3.  **Screen 3 (Recommendation):**
    - Render the list based on the _fixed_ JSON data.
    - The "Join Deal" button uses the `deal_uuid` from the JSON.
4.  **Screen 4 (Calculator):**
    - Clone the quantities into `customQuantities`.
    - Allow UI updates.
    - Ensure the "Join" button handles the revert-to-standard logic explained in Section 3.
5.  **Confirmation Logic:**
    - Implement the API call `POST /participate`.

## 6. Corner Case Handling

- **Zero Quantity:** If a user reduces quantity to 0 in Customization, remove the item cost from the total, but keep the row (faded) so they can add it back.
- **No Data:** If `assets/json/farming_data.json` fails to load, show a generic error "Catalog unavailable".
- **Unit Display:** Ensure distinct display for "Litre", "Kg", "ml". (e.g., if qty is < 1, display in ml/g is better UX, but sticking to raw decimals 0.5 L is fine for V1).

This specification allows you to build the full frontend visual flow and "Calculator" utility immediately, while ensuring the "Join Deal" button actually works with your existing backend limitations.
