#!/usr/bin/env python3
"""
LSP Basic JSON Structures using Pydantic
Based on LSP Specification 3.17
https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/
"""

from typing import Optional, List, Dict, Any, Union, Literal
from pydantic import BaseModel, Field
import json


# Basic JSON Structures

class Position(BaseModel):
    """Position in a text document expressed as zero-based line and character offset."""
    line: int = Field(ge=0, description="Line position in a document (zero-based)")
    character: int = Field(ge=0, description="Character offset on a line in a document (zero-based)")


class Range(BaseModel):
    """A range in a text document expressed as start and end positions."""
    start: Position
    end: Position


class Location(BaseModel):
    """Represents a location inside a resource."""
    uri: str = Field(description="Document URI")
    range: Range


class LocationLink(BaseModel):
    """Represents a link between a source and a target location."""
    originSelectionRange: Optional[Range] = None
    targetUri: str
    targetRange: Range
    targetSelectionRange: Range


class Diagnostic(BaseModel):
    """Represents a diagnostic, such as a compiler error or warning."""
    range: Range
    severity: Optional[int] = Field(None, ge=1, le=4)  # 1=Error, 2=Warning, 3=Information, 4=Hint
    code: Optional[Union[int, str]] = None
    codeDescription: Optional[Dict[str, Any]] = None
    source: Optional[str] = None
    message: str
    tags: Optional[List[int]] = None  # 1=Unnecessary, 2=Deprecated
    relatedInformation: Optional[List["DiagnosticRelatedInformation"]] = None
    data: Optional[Any] = None


class DiagnosticRelatedInformation(BaseModel):
    """Represents a related message and source code location for a diagnostic."""
    location: Location
    message: str


class Command(BaseModel):
    """Represents a reference to a command."""
    title: str
    command: str
    arguments: Optional[List[Any]] = None


class TextEdit(BaseModel):
    """A textual edit applicable to a text document."""
    range: Range
    newText: str


class TextDocumentEdit(BaseModel):
    """Describes textual changes on a single text document."""
    textDocument: "OptionalVersionedTextDocumentIdentifier"
    edits: List[Union[TextEdit, "AnnotatedTextEdit"]]


class WorkspaceEdit(BaseModel):
    """A workspace edit represents changes to many resources managed in the workspace."""
    changes: Optional[Dict[str, List[TextEdit]]] = None
    documentChanges: Optional[List[Union[TextDocumentEdit, "CreateFile", "RenameFile", "DeleteFile"]]] = None
    changeAnnotations: Optional[Dict[str, "ChangeAnnotation"]] = None


class TextDocumentIdentifier(BaseModel):
    """Text document identifier."""
    uri: str


class VersionedTextDocumentIdentifier(TextDocumentIdentifier):
    """Versioned text document identifier."""
    version: int


class OptionalVersionedTextDocumentIdentifier(TextDocumentIdentifier):
    """Optional versioned text document identifier."""
    version: Optional[int] = None


class TextDocumentPositionParams(BaseModel):
    """Parameters for requests that need a text document and position."""
    textDocument: TextDocumentIdentifier
    position: Position


class DocumentFilter(BaseModel):
    """A document filter denotes a document through properties."""
    language: Optional[str] = None
    scheme: Optional[str] = None
    pattern: Optional[str] = None


DocumentSelector = List[DocumentFilter]


class TextDocumentItem(BaseModel):
    """An item to transfer a text document from the client to the server."""
    uri: str
    languageId: str
    version: int
    text: str


class MarkupContent(BaseModel):
    """A MarkupContent literal represents human-readable content."""
    kind: Literal["plaintext", "markdown"]
    value: str


class WorkDoneProgressParams(BaseModel):
    """Parameters to report work done progress."""
    workDoneToken: Optional[Union[int, str]] = None


class PartialResultParams(BaseModel):
    """Parameters for partial result support."""
    partialResultToken: Optional[Union[int, str]] = None


# Message structures

class Message(BaseModel):
    """Base message structure."""
    jsonrpc: Literal["2.0"] = "2.0"


class RequestMessage(Message):
    """Request message."""
    id: Union[int, str]
    method: str
    params: Optional[Union[List, Dict[str, Any]]] = None


class ResponseMessage(Message):
    """Response message."""
    id: Union[int, str]
    result: Optional[Any] = None
    error: Optional["ResponseError"] = None


class NotificationMessage(Message):
    """Notification message."""
    method: str
    params: Optional[Union[List, Dict[str, Any]]] = None


class ResponseError(BaseModel):
    """Error object returned in response messages."""
    code: int
    message: str
    data: Optional[Any] = None


# Additional models for completeness

class ChangeAnnotation(BaseModel):
    """Additional information that describes document changes."""
    label: str
    needsConfirmation: Optional[bool] = None
    description: Optional[str] = None


class AnnotatedTextEdit(TextEdit):
    """Text edit with annotation."""
    annotationId: str


class CreateFile(BaseModel):
    """Create file operation."""
    kind: Literal["create"] = "create"
    uri: str
    options: Optional[Dict[str, Any]] = None
    annotationId: Optional[str] = None


class RenameFile(BaseModel):
    """Rename file operation."""
    kind: Literal["rename"] = "rename"
    oldUri: str
    newUri: str
    options: Optional[Dict[str, Any]] = None
    annotationId: Optional[str] = None


class DeleteFile(BaseModel):
    """Delete file operation."""
    kind: Literal["delete"] = "delete"
    uri: str
    options: Optional[Dict[str, Any]] = None
    annotationId: Optional[str] = None


# Update forward references
Diagnostic.model_rebuild()
WorkspaceEdit.model_rebuild()
TextDocumentEdit.model_rebuild()


# Export examples
def export_examples():
    """Export example JSON structures for testing."""
    
    # Example position
    pos = Position(line=10, character=5)
    print("Position example:")
    print(json.dumps(pos.model_dump(), indent=2))
    print()
    
    # Example range
    range_obj = Range(
        start=Position(line=10, character=5),
        end=Position(line=10, character=15)
    )
    print("Range example:")
    print(json.dumps(range_obj.model_dump(), indent=2))
    print()
    
    # Example diagnostic
    diagnostic = Diagnostic(
        range=range_obj,
        severity=1,  # Error
        code="E001",
        source="ruby-lsp",
        message="Undefined method 'foo' for nil:NilClass"
    )
    print("Diagnostic example:")
    print(json.dumps(diagnostic.model_dump(), indent=2))
    print()
    
    # Example request message
    request = RequestMessage(
        id=1,
        method="textDocument/completion",
        params={
            "textDocument": {"uri": "file:///path/to/mal_minimal.rb"},
            "position": {"line": 10, "character": 5}
        }
    )
    print("Request message example:")
    print(json.dumps(request.model_dump(), indent=2))
    print()
    
    # Example response message
    response = ResponseMessage(
        id=1,
        result={
            "items": [
                {
                    "label": "cons",
                    "kind": 3,  # Function
                    "detail": "cons(car, cdr) -> Cons"
                }
            ]
        }
    )
    print("Response message example:")
    print(json.dumps(response.model_dump(), indent=2))
    print()
    
    # Example notification
    notification = NotificationMessage(
        method="textDocument/publishDiagnostics",
        params={
            "uri": "file:///path/to/mal_minimal.rb",
            "diagnostics": [diagnostic.model_dump()]
        }
    )
    print("Notification message example:")
    print(json.dumps(notification.model_dump(), indent=2))


if __name__ == "__main__":
    print("LSP Basic JSON Structures")
    print("=========================")
    print()
    export_examples()
    
    # Export all models to JSON schema
    with open("lsp-structures-schema.json", "w") as f:
        schema = {
            "Position": Position.model_json_schema(),
            "Range": Range.model_json_schema(),
            "Location": Location.model_json_schema(),
            "Diagnostic": Diagnostic.model_json_schema(),
            "TextEdit": TextEdit.model_json_schema(),
            "RequestMessage": RequestMessage.model_json_schema(),
            "ResponseMessage": ResponseMessage.model_json_schema(),
            "NotificationMessage": NotificationMessage.model_json_schema()
        }
        json.dump(schema, f, indent=2)
    
    print("\nJSON schemas exported to lsp-structures-schema.json")