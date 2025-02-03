/* reposyd-reportblock-header */
const ReportBlock = require( 'ReportFramework' ).ReportBlock
const ReportTable = require( 'ReportFramework' ).ReportTable
const Utils = require( 'Utils' )
/* reposyd-reportblock-header */
class ReportBlockFunctionalBreakdown extends ReportBlock {
  constructor( section, engine ) {
    super( section, engine )
    /* reposyd-reportblock-constructor */
    this.sectionNumber = new Utils.LexicographicalOrder.SectionNumber( this.section.number )
    /* reposyd-reportblock-constructor */
    this.translations = {
      /* reposyd-reportblock-translations */
      de: {
        description: 'Beschreibung',
        in: 'Eingabe',
        out: 'Ausgabe',
        title: 'Titel',
        type: 'Typ'
      },
      en: {
        description: 'Description',
        in: 'Input',
        out: 'Output',
        title: 'Title',
        type: 'Type'
      }
      /* reposyd-reportblock-translations */
    }
  }
  /* reposyd-reportblock-body */
  renderContent() {
    const self = this
    this.format.writeHtml( this.section.text, 'description' )

    const fn = this.designData.designDataObject( this.section.reportblock.options.reportblock.startingpoint )
    if ( !fn ) {

    } else {
      self.sectionNumber.add()
      followBreakdown( fn )
    }

    function followBreakdown( fn ) {
      self.addSection( self.sectionNumber.toString(), fn.attributes.title )
      if ( self.section.reportblock.options.reportblock.diagramtype !== 'none' ) {
        self.designData.modeling.object.diagrams( fn.uuid, self.section.reportblock.options.reportblock.diagramtype ).forEach( dm => {
          self.writeDiagram( dm )
        } )
      }
      self.writeHtml( fn.attributes.description, 'description' )
      let interfaceItems = self.designData.designDataLinks( fn, 'hasoutputs', 'II' ).map( x => { return { dir: 'out', ddo: x.ddo } } )
      interfaceItems = interfaceItems.concat( self.designData.designDataLinks( fn, 'hasinputs', 'II' ).map( x => { return { dir: 'in', ddo: x.ddo } } ) )
      if ( interfaceItems.length > 0 ) {
        const table = new ReportTable.Table( 0, 3 )
        table.horizontalHeader.setStyle( -1, 'tableHeader' )
        table.horizontalHeader.addRow()
        table.horizontalHeader.setCaption( 0, this.tc( 'titel' ) )
        table.horizontalHeader.setCaption( 1, this.tc( 'typ' ) )
        table.horizontalHeader.setWidth( 1, 20 )
        table.horizontalHeader.setCaption( 2, this.tc( 'description' ) )
        interfaceItems.forEach( item => {
          const row = table.appendRow()
          row.cell( 0 ).setData( item.ddo.attributes.title )
          row.cell( 1 ).setData( item.dir === 'in' ? this.tc( 'in' ) : this.tc( 'out' ) )
          row.cell( 2 ).setData( `<html><body>${item.ddo.attributes.description}</body></html>` )
        } )
        self.writeTable( table )
      }

      self.sectionNumber.add()
      const dd = this.designDataObjectDefinition( 'FN' )
      dd.attributes.number.type = 'number'
      Utils.Sort.byAttributes( self.designData.designDataLinks( fn, 'dividedinto', 'FN' ).map( x => x.ddo ), [dd.attributes.number, dd.attributes.title] )
        .forEach( item => {
          followBreakdown( item )
        } )

      self.sectionNumber.remove()

      self.sectionNumber.inc()
    }
  }
  /* reposyd-reportblock-body */
  static RuleDefinition( settings ) {
    var rule = ReportBlockRequirements.DefaultSettings( settings ).rule;
    return rule === undefined ? null : rule
  }
  static DefaultSettings( settings ) {
    return {
      /* reposyd-reportblock-settings */
      section: [{
        id: 'pageBreak',
        title: {
          'de-DE': 'Seitenumbruch',
          'en-US': 'Page Break'
        },
        type: 'boolean',
        value: false
      }],
      reportblock: [
        {
          id: 'startingpoint',
          title: {
            'de-DE': 'Startpunkt',
            'en-US': 'Starting point'
          },
          type: 'select',
          options: 'FN',
          selection: 'single',
          value: 'none'
        },
        {
          id: 'diagramtype',
          title: {
            'de-DE': 'Diagramart',
            'en-US': 'Diagram type'
          },
          type: 'select',
          options: [
            { label: 'common.none', value: 'none' },
            { label: 'common.actd', value: 'actd' }
          ],
          selection: 'single',
          value: 'none'
        }
      ]
    }
    /* reposyd-reportblock-settings */
  }
}

module.exports = ReportBlockFunctionalBreakdown
