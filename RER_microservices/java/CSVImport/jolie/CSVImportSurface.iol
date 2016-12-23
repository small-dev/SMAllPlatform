type GetLinesRequest: void {
  .filename: string
}

type GetLinesResponse: void {
  .lines: int
}

type ImportFileRequest: void {
  .separator: string
  .filename: string
  .verbose?: bool
}

type ImportFileResponse: void {
  .line*: void { ? }
}

type ImportFileBunchRequest: void {
  .filename: string
  .separator: string
  .verbose?:bool
  .fromLine: int
  .toLine:int
}

interface CSVImportInterface {
  RequestResponse:
    getLines( GetLinesRequest )( GetLinesResponse ) throws FileNotFound IOException,
    importFile( ImportFileRequest )( ImportFileResponse ) throws FileNotFound IOException,
    importFileBunch( ImportFileBunchRequest )( ImportFileResponse ) throws FileNotFound IOException
}

outputPort CSVImport {
  Interfaces: CSVImportInterface
}

embedded {
  Java:
    "small.utilities.CSVImport" in CSVImport
}
