codeunit 50900 Webservices
{
    trigger OnRun()
    begin
    end;

    procedure Ping(): Text
    begin
        exit('Pong');
    end;

    procedure InsertItemFromJson(jsontext: Text): Text
    var
        Item: Record Item;
        JsonInput, JsonObject : JsonObject;
        JsonArray: JsonArray;
        JSONProperty: JsonObject;
        ParamToken, ParamsJToken : JsonToken;
        No: Code[20];
        Description: Text[100];
        UoM: Code[10];
        UnitCost, UnitPrice : Decimal;
        BigText: Text;
    begin
        if not JsonArray.ReadFrom(jsontext) then
            Error('Problem reading Json!');

        foreach ParamToken in JsonArray do begin
            JsonObject := ParamToken.AsObject();
            No := ValidateJsonToken(JsonObject, 'No').AsValue().AsCode();
            Description := ValidateJsonToken(JsonObject, 'Description').AsValue().AsText();
            UoM := ValidateJsonToken(JsonObject, 'UnitOfMeasure').AsValue().AsCode();
            UnitCost := ValidateJsonToken(JsonObject, 'UnitCost').AsValue().AsDecimal();
            UnitPrice := ValidateJsonToken(JsonObject, 'UnitPrice').AsValue().AsDecimal();

            Item.Init();
            Item."No." := No;
            Item.Description := Description;
            Item."Base Unit of Measure" := UoM;
            Item."Unit Cost" := UnitCost;
            Item."Unit Price" := UnitPrice;
            if not Item.Insert() then
                Item.Modify();
        end;

        JSONProperty.Add('IsSuccess', true);
        JSONProperty.Add('Message', 'The Items array has been inserted successfully.');
        JSONProperty.WriteTo(BigText);
        exit(BigText);
    end;

    local procedure ValidateJsonToken(JsonObject: JsonObject; TokenKey: text) JsonToken: JsonToken
    begin
        if not JsonObject.Get(TokenKey, JsonToken) then
            Error('Could not find token with key: %1', TokenKey);
    end;

}